param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("start","stop")]
    [string]$Action
)

# =============================================
# 현재 환경 실제 리소스 ID (2026-06-29 기준)
# =============================================
$bastionInstanceIds = @(
    "i-0bb965dd58ce00ed8",   # team5-dev-bastion
    "i-0b50d25628e09256d"    # team5-prod-bastion
)
# replica는 수동 start/stop 불가 (Primary 상태에 따라 자동 관리됨)
$rdsIdentifiers = @("team5-dev-rds", "team5-prod-rds")

if ($Action -eq "stop") {
    Write-Host "========== [STOP] 순서: APP -> BASTION -> DB ==========" -ForegroundColor Yellow

    # 1. App 먼저 죽여서 DB 커넥션부터 해제
    Write-Host "1. EKS Node Groups 스케일 다운..." -ForegroundColor Cyan
    aws eks update-nodegroup-config --cluster-name team5-dev-eks  --nodegroup-name team5-dev-eks-app-ng  --scaling-config minSize=0,maxSize=1,desiredSize=0
    aws eks update-nodegroup-config --cluster-name team5-prod-eks --nodegroup-name team5-prod-eks-app-ng --scaling-config minSize=0,maxSize=1,desiredSize=0

    # 2. Bastion 정지
    Write-Host "2. Bastion 인스턴스 정지..." -ForegroundColor Cyan
    aws ec2 stop-instances --instance-ids $bastionInstanceIds

    # 3. Replica 먼저 정지 (Primary보다 먼저)
    Write-Host "3. RDS Replica 정지..." -ForegroundColor Cyan
    aws rds stop-db-instance --db-instance-identifier $rdsReplicaIdentifier

    # 4. Primary DB 정지
    Write-Host "4. RDS Primary 정지..." -ForegroundColor Cyan
    foreach ($rds in $rdsIdentifiers) {
        aws rds stop-db-instance --db-instance-identifier $rds
    }

    Write-Host "-> 모든 자원 안전하게 정지 완료!" -ForegroundColor Green
}
elseif ($Action -eq "start") {
    Write-Host "========== [START] 순서: DB(대기) -> BASTION -> APP ==========" -ForegroundColor Yellow

    # 1. Primary DB 시작 (이미 running이면 건너뜀)
    Write-Host "1. RDS Primary 인스턴스 시작 요청..." -ForegroundColor Cyan
    foreach ($rds in $rdsIdentifiers) {
        $state = (aws rds describe-db-instances --db-instance-identifier $rds --query "DBInstances[0].DBInstanceStatus" --output text 2>$null)
        if ($state -eq "stopped") {
            Write-Host "   -> $rds 시작 중..." -ForegroundColor Gray
            aws rds start-db-instance --db-instance-identifier $rds | Out-Null
        } else {
            Write-Host "   -> $rds 이미 $state 상태, 건너뜀" -ForegroundColor Gray
        }
    }

    # [핵심] Primary RDS가 완전히 켜질 때까지 대기
    Write-Host "-> Primary DB 가동 대기 중 (수 분 소요)..." -ForegroundColor Gray
    foreach ($rds in $rdsIdentifiers) {
        aws rds wait db-instance-available --db-instance-identifier $rds
    }
    Write-Host "-> 모든 Primary DB가 사용 가능한 상태입니다!" -ForegroundColor Green
    # ※ Replica는 Primary 가동 후 AWS가 자동으로 복구함 (수동 start 불필요)

    # 2. Bastion 인스턴스 시작...
    Write-Host "2. Bastion 인스턴스 시작..." -ForegroundColor Cyan
    aws ec2 start-instances --instance-ids $bastionInstanceIds

    # 3. EKS 노드 그룹 원상복구 (DB가 뜬 뒤에만 실행됨)
    Write-Host "3. EKS Node Groups 스케일 업..." -ForegroundColor Cyan
    aws eks update-nodegroup-config --cluster-name team5-dev-eks  --nodegroup-name team5-dev-eks-app-ng  --scaling-config minSize=1,maxSize=3,desiredSize=2
    aws eks update-nodegroup-config --cluster-name team5-prod-eks --nodegroup-name team5-prod-eks-app-ng --scaling-config minSize=3,maxSize=8,desiredSize=3

    Write-Host "========== 모든 인프라 정상 재가동 완료! ==========" -ForegroundColor Yellow
}