# Team 5 Ticketing Platform - Infrastructure as Code (IaC)

이 저장소는 **High-Availability & Elastic Ticketing Platform**의 AWS 클라우드 인프라를 정의하는 Terraform 코드 저장소입니다.  
폭발적인 트래픽 폭주 환경에서 고가용성과 무결성을 보장하기 위해 설계되었으며, `modules/`와 `envs/`의 재사용 가능한 구조로 설계되어 있습니다.

---

## 📂 프로젝트 구조 (Directory Structure)

```
team5-ticket-infra/
├── bootstrap-backend/      # S3 State Bucket & DynamoDB Lock Table 생성 (최초 1회 실행)
├── modules/                # 재사용 가능한 테라폼 인프라 모듈
│   ├── network/            # VPC, 3-Tier Subnets, IGW, NAT Gateways, Routing Tables
│   ├── bastion/            # SSM-only EC2 Bastion Host (IMDSv2 적용)
│   ├── eks/                # EKS Cluster, Node Group, IAM Role
│   ├── database/           # RDS MySQL (Multi-AZ, Read Replica)
│   ├── elasticache/        # ElastiCache Redis Cluster
│   └── ...
└── envs/                   # 환경별(Dev / Prod) 실행 래퍼 테라폼 구성
    ├── dev/
    │   ├── infra/          # dev 환경 AWS 리소스 프로비저닝 (VPC, EKS, RDS, Redis 등)
    │   └── platform-addons/# dev 환경 K8s 애드온 구성 (ALB Controller, KEDA, ESO 등)
    └── prod/
        ├── infra/          # prod 환경 AWS 리소스 프로비저닝
        └── platform-addons/# prod 환경 K8s 애드온 구성
```

---

## 🛠️ 담당자 및 역할 분담 (IaC & Network Master)

* **담당 영역**: [modules/network](file:///C:/CE/team5/team5-ticket-infra/modules/network) 및 [modules/bastion](file:///C:/CE/team5/team5-ticket-infra/modules/bastion)
* **담당 핵심 업무**:
  1. **VPC 및 3-Tier 서브넷 설계**: 가용 영역 3개 분할 및 Public / Private / Database 망 논리적 격리
  2. **비용 효율적 NAT 설계**: Dev 환경 Single NAT, Prod 환경 Multi-AZ NAT 자동 전환 제어
  3. **SSM Bastion 보안 강화**: SSH Port 22 차단, SSM Session Manager 연동, IMDSv2 메타데이터 보안 강화
  4. **State 백엔드 부트스트랩**: S3 State 및 DynamoDB Lock Backend 초기 구성 관리 ([bootstrap-backend](file:///C:/CE/team5/team5-ticket-infra/bootstrap-backend))

---

## 🚀 배포 가이드 (Deployment Guide)

### Step 1. S3 State 백엔드 초기화 (최초 1회)
Terraform 상태 파일(`.tfstate`) 공유를 위해 S3 및 DynamoDB 락 테이블을 생성합니다.
```bash
cd bootstrap-backend
terraform init
terraform apply
```

### Step 2. 개발 환경 인프라 배포 (dev/infra)
공통 네트워크(VPC)를 시작으로 EKS, RDS, Redis 등의 핵심 리소스를 프로비저닝합니다.
```bash
cd ../envs/dev/infra
terraform init
terraform apply
```

---

## 🛡️ 보안 하드닝 규칙 (Security Hardening Rules)

* **SSM-Only Access**: Bastion 호스트의 SSH 포트인 22번 포트는 보안 위협을 방어하기 위해 상시 차단되어 있습니다.
* **IMDSv2 강제**: 모든 EC2 인스턴스는 최신의 세션 토큰 방식 메타데이터 서비스(IMDSv2)를 사용합니다.
* **DB 접근 통제**: 데이터베이스 망(`Database Subnets`)은 외부 인터넷 연결이 존재하지 않으며, Private Subnet(EKS Nodes) 및 Bastion SG로부터의 통신만 수용합니다.