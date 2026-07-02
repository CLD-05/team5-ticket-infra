param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("start","stop")]
    [string]$Action
)

# Resource IDs verified 2026-06-30
# prod RDS: Has active Read-Replica -> CLI stop blocked by AWS (must delete replica first to stop primary)
# dev RDS: Single DB (no replica) -> CLI stop/start OK

$bastionInstanceIds = @(
    "i-09ad9bbb025cb1622",   # team5-dev-bastion
    "i-0b43ea7a1ce278ee3"    # team5-prod-bastion
)
$rdsDevIds  = @("team5-dev-rds")
$rdsProdIds = @("team5-prod-rds", "team5-prod-rds-replica")

if ($Action -eq "stop") {
    Write-Host "=== [STOP] APP -> BASTION -> DB ===" -ForegroundColor Yellow

    Write-Host "1. EKS scale down..." -ForegroundColor Cyan
    aws eks update-nodegroup-config --cluster-name team5-dev-eks  --nodegroup-name team5-dev-eks-app-ng  --scaling-config minSize=0,maxSize=1,desiredSize=0
    aws eks update-nodegroup-config --cluster-name team5-prod-eks --nodegroup-name team5-prod-eks-app-ng --scaling-config minSize=0,maxSize=1,desiredSize=0

    Write-Host "2. Stopping Bastion instances..." -ForegroundColor Cyan
    aws ec2 stop-instances --instance-ids $bastionInstanceIds
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   [WARN] IAM denied. Stop Bastions manually:" -ForegroundColor Yellow
        Write-Host "     dev-bastion:  i-09ad9bbb025cb1622" -ForegroundColor Yellow
        Write-Host "     prod-bastion: i-0b43ea7a1ce278ee3" -ForegroundColor Yellow
    } else {
        Write-Host "   Bastion stop OK" -ForegroundColor Green
    }

    Write-Host "3. Stopping dev RDS..." -ForegroundColor Cyan
    foreach ($rds in $rdsDevIds) {
        $st = (aws rds describe-db-instances --db-instance-identifier $rds --query "DBInstances[0].DBInstanceStatus" --output text 2>$null)
        if ($st -eq "available") {
            Write-Host "   $rds stop requested" -ForegroundColor Gray
            aws rds stop-db-instance --db-instance-identifier $rds | Out-Null
            Write-Host "   $rds stop OK" -ForegroundColor Green
        } else {
            Write-Host "   $rds is $st, skipping" -ForegroundColor Gray
        }
    }

    Write-Host ""
    Write-Host "   [INFO] prod RDS: Stop blocked by AWS because it has an active Read Replica." -ForegroundColor Yellow
    foreach ($rds in $rdsProdIds) {
        $st = (aws rds describe-db-instances --db-instance-identifier $rds --query "DBInstances[0].DBInstanceStatus" --output text 2>$null)
        Write-Host "     $rds -> $st" -ForegroundColor Yellow
    }
    Write-Host "   To stop: You must delete the Read Replica first, then stop the Primary DB." -ForegroundColor Yellow

    Write-Host "4. Waiting for dev RDS to stop..." -ForegroundColor Cyan
    foreach ($rds in $rdsDevIds) {
        do {
            Start-Sleep -Seconds 15
            $st = (aws rds describe-db-instances --db-instance-identifier $rds --query "DBInstances[0].DBInstanceStatus" --output text 2>$null)
            Write-Host "   $rds -> $st" -ForegroundColor Gray
        } while ($st -ne "stopped")
        Write-Host "   $rds stopped" -ForegroundColor Green
    }

    Write-Host "=== STOP done. prod RDS needs manual action in Console. ===" -ForegroundColor Yellow
}
elseif ($Action -eq "start") {
    Write-Host "=== [START] DB -> BASTION -> APP ===" -ForegroundColor Yellow

    Write-Host "1. Starting dev RDS..." -ForegroundColor Cyan
    foreach ($rds in $rdsDevIds) {
        $st = (aws rds describe-db-instances --db-instance-identifier $rds --query "DBInstances[0].DBInstanceStatus" --output text 2>$null)
        if ($st -eq "stopped") {
            aws rds start-db-instance --db-instance-identifier $rds | Out-Null
            Write-Host "   $rds start requested" -ForegroundColor Gray
        } else {
            Write-Host "   $rds is $st, skipping" -ForegroundColor Gray
        }
    }
    foreach ($rds in $rdsProdIds) {
        $st = (aws rds describe-db-instances --db-instance-identifier $rds --query "DBInstances[0].DBInstanceStatus" --output text 2>$null)
        Write-Host "   $rds -> $st (prod: always managed by AWS)" -ForegroundColor Gray
    }
    Write-Host "   Waiting for dev RDS available..." -ForegroundColor Gray
    foreach ($rds in $rdsDevIds) {
        aws rds wait db-instance-available --db-instance-identifier $rds
        Write-Host "   $rds available" -ForegroundColor Green
    }

    Write-Host "2. Starting Bastion instances..." -ForegroundColor Cyan
    aws ec2 start-instances --instance-ids $bastionInstanceIds
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   [WARN] IAM denied. Start Bastions manually:" -ForegroundColor Yellow
        Write-Host "     dev-bastion:  i-09ad9bbb025cb1622" -ForegroundColor Yellow
        Write-Host "     prod-bastion: i-0b43ea7a1ce278ee3" -ForegroundColor Yellow
    } else {
        Write-Host "   Bastion start OK" -ForegroundColor Green
    }

    Write-Host "3. EKS scale up..." -ForegroundColor Cyan
    aws eks update-nodegroup-config --cluster-name team5-dev-eks  --nodegroup-name team5-dev-eks-app-ng  --scaling-config minSize=1,maxSize=5,desiredSize=2
    aws eks update-nodegroup-config --cluster-name team5-prod-eks --nodegroup-name team5-prod-eks-app-ng --scaling-config minSize=3,maxSize=8,desiredSize=3

    Write-Host "=== All infra started. ===" -ForegroundColor Yellow
}