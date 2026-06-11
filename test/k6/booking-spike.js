import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter, Rate, Trend } from 'k6/metrics';

// ===== 환경변수 =====
const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const SHOW_ID = __ENV.SHOW_ID || '1';
const SEAT_MIN = parseInt(__ENV.SEAT_ID_MIN || '1');
const SEAT_MAX = parseInt(__ENV.SEAT_ID_MAX || '2000');
const USER_COUNT = parseInt(__ENV.USER_COUNT || '50');
const PASSWORD = __ENV.TEST_PASSWORD || 'test1234';
const USE_QUEUE_TOKEN = (__ENV.USE_QUEUE_TOKEN || 'false') === 'true'; // false=A(우회), true=B(실토큰)
const POLL_TIMEOUT_MS = parseInt(__ENV.POLL_TIMEOUT_MS || '30000');

// ===== 커스텀 메트릭 =====
const holdOk = new Counter('seat_hold_ok');
const holdConflict = new Counter('seat_hold_conflict');
const bookingAccepted = new Counter('booking_accepted');         // SQS 발행(202)
const confirmed = new Counter('booking_confirmed');        // 최종 CONFIRMED
const conflicted = new Counter('booking_conflict');         // CONFLICT (정상 거절)
const failed = new Counter('booking_failed');           // FAILED (시스템 실패)
const pollTimeout = new Counter('booking_poll_timeout');     // 타임아웃 내 미확정
const e2eConfirm = new Trend('booking_e2e_confirm_ms', true); // ★ 진짜 SLI
const confirmRate = new Rate('booking_confirm_rate');

// ===== 부하 시나리오 2: 큐 스파이크 → KEDA/CA 관찰 =====
export const options = {
  scenarios: {
    queue_spike: {
      executor: 'ramping-arrival-rate',
      startRate: 5, timeUnit: '1s',
      preAllocatedVUs: 100, maxVUs: 800,   // 폴링까지 하므로 VU 여유 크게
      stages: [
        { target: 5, duration: '30s' },  // 워밍업
        { target: 300, duration: '20s' },  // 스파이크 ↑ (적체 시작)
        { target: 300, duration: '120s' }, // 고부하 유지 (KEDA Pod↑ → CA Node↑)
        { target: 5, duration: '60s' },  // 진정 (scale-down)
      ],
    },
  },
  thresholds: {
    booking_confirm_rate: ['rate>0.4'],   // 발행분 중 40%+ 최종 확정
    booking_e2e_confirm_ms: ['p(99)<5000'], // 문서 SLO: e2e p99 < 5s
  },
};

// ===== setup: 유저 생성/로그인 → (B면)큐토큰 → 풀 =====
export function setup() {
  const users = [];
  for (let i = 0; i < USER_COUNT; i++) {
    const email = `loadtest_${i}@example.com`;
    const json = { headers: { 'Content-Type': 'application/json' } };

    http.post(`${BASE_URL}/api/v1/auth/signup`,
      JSON.stringify({ email, password: PASSWORD, name: `load${i}` }), json);

    const res = http.post(`${BASE_URL}/api/v1/auth/login`,
      JSON.stringify({ email, password: PASSWORD }), json);
    if (res.status !== 200) continue;

    const body = res.json();
    const u = { userId: body.userId, jwt: body.accessToken };

    if (USE_QUEUE_TOKEN) {
      const enter = http.post(`${BASE_URL}/api/v1/shows/${SHOW_ID}/queue/enter`, null,
        { headers: { Authorization: `Bearer ${u.jwt}` } });
      if (enter.status === 200) u.queueToken = enter.json().queueToken;
    }
    users.push(u);
  }
  if (users.length === 0) throw new Error('로그인 가능한 테스트 유저 0명 — 계정/seed 확인');
  console.log(`users=${users.length} mode=${USE_QUEUE_TOKEN ? 'B(queue-token)' : 'A(bypass)'}`);
  return { users };
}

// ===== default: hold → booking → status 폴링(e2e 측정) =====
export default function (data) {
  const u = data.users[Math.floor(Math.random() * data.users.length)];

  const span = SEAT_MAX - SEAT_MIN + 1;
  const seatId = SEAT_MIN + ((__VU * 131 + __ITER) % span);

  const headers = { Authorization: `Bearer ${u.jwt}`, 'Content-Type': 'application/json' };
  if (USE_QUEUE_TOKEN && u.queueToken) headers['X-Queue-Token'] = u.queueToken;

  // 1) 좌석 선점
  const hold = http.post(`${BASE_URL}/api/v1/seats/${seatId}/hold`, null, { headers });
  if (hold.status !== 200) { holdConflict.add(1); return; }
  holdOk.add(1);

  // 2) 예매 요청 → SQS 발행 (⚠️ A모드는 ?seatId= 쿼리파라미터)
  const booking = http.post(`${BASE_URL}/api/v1/bookings?seatId=${seatId}`, null, { headers });
  if (booking.status !== 202) return;
  bookingAccepted.add(1);
  const reqId = booking.json('requestId');

  // 3) status 폴링 → CONFIRMED/CONFLICT/FAILED 까지. e2e 확정시간 = POST 수락→최종확정 (진짜 SLI)
  const start = Date.now();
  let status = 'PROCESSING';
  while (status === 'PROCESSING' && Date.now() - start < POLL_TIMEOUT_MS) {
    sleep(0.5);
    const st = http.get(`${BASE_URL}/api/v1/bookings/status/${reqId}`, { headers });
    if (st.status === 200) status = st.json('status');
  }

  const elapsed = Date.now() - start;
  if (status === 'CONFIRMED') {
    confirmed.add(1); confirmRate.add(true); e2eConfirm.add(elapsed);
  } else if (status === 'CONFLICT') {
    conflicted.add(1); confirmRate.add(false);   // 정상 거절: 확정엔 실패지만 시스템 에러 아님
  } else if (status === 'FAILED') {
    failed.add(1); confirmRate.add(false);
  } else {
    pollTimeout.add(1); confirmRate.add(false);  // 타임아웃 내 미확정 (워커 적체 심함 신호)
  }
  check(booking, { 'booking 202 accepted': () => true });
}