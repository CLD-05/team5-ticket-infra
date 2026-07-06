# 🏗️ Team5 Ticket Infrastructure (team5-ticket-infra)

> **AWS Infrastructure as Code (IaC) Repository**  
> Ticket Wave 티켓팅 플랫폼의 AWS 인프라(VPC, EKS, RDS Proxy, ElastiCache, SQS, S3, WAF, Route53 등)를 Terraform으로 모듈화하여 관리하는 IaC 저장소입니다.

---

## 📋 1. 개요 및 설계 목표

이 저장소는 대규모 부하와 트래픽 폭주 환경을 수용하기 위한 **안정성**, **고가용성**, **환경 격리(Dev/Prod)** 및 **보안 Hardening**을 목표로 설계된 AWS 인프라 코드입니다.

### 🌟 핵심 설계 목표
- **VPC 수준 환경 완벽 격리**: Dev(`10.5.0.0/17`) 및 Prod(`10.5.128.0/17`) 네트워크 분리.
- **EKS 클러스터 분리**: EKS 1.35 기반 클러스터 구축, Pod Identity 및 IRSA 권한 체계 적용.
- **데이터베이스 커넥션 보호**: RDS MySQL 앞단에 RDS Proxy를 배치하여 Connection Pool 고갈 및 Failover 시 커넥션 유실 방지.
- **고가용성(HA) 구조**: Prod 환경 3AZ Multi-AZ RDS, Multi NAT Gateway 및 ElastiCache Redis Replication Group 적용.
- **Passwordless CI/CD**: AWS Long-lived Access Key를 폐지하고 GitHub Actions OIDC 기반 IAM Role Assume 적용.

---

## 🏗️ 2. 아키텍처 & 네트워크 레이아웃

```text
[Internet / Route53 / CloudFront]
               │
               ▼
[AWS WAF] ──► [Public Subnet: ALB / NAT Gateway / SSM Bastion]
               │
               ▼
[Private Subnet: EKS Worker Nodes / Pods (ticketing namespace)]
               │
               ▼
[Database Subnet: RDS Proxy ──► RDS MySQL (Multi-AZ) / ElastiCache Redis / SQS]
```

### CIDR 및 네트워크 대역 분리

| 구분 | Dev 환경 (2 AZ) | Prod 환경 (3 AZ) |
|---|---|---|
| **VPC CIDR** | `10.5.0.0/17` | `10.5.128.0/17` |
| **Public Subnet** | `10.5.0.0/24`, `10.5.1.0/24` | `10.5.128.0/24`, `10.5.129.0/24`, `10.5.130.0/24` |
| **Private Subnet** | `10.5.16.0/20`, `10.5.32.0/20` | `10.5.144.0/20`, `10.5.160.0/20`, `10.5.176.0/20` |
| **Database Subnet** | `10.5.48.0/24`, `10.5.49.0/24` | `10.5.240.0/24`, `10.5.241.0/24`, `10.5.242.0/24` |
| **NAT Gateway** | Single NAT (비용 절감) | Multi NAT (AZ별 3개 배치로 HA 확보) |

---

## 📂 3. 저장소 구조 (Modules & Envs)

```text
team5-ticket-infra/
├── bootstrap-backend/              # Terraform S3 State Backend 생성
│
├── modules/                        # 재사용 가능한 Terraform 모듈
│   ├── network/                    # VPC, Subnet, NAT Gateway, Route Table
│   ├── bastion/                    # SSM Session Manager Bastion Host
│   ├── eks/                        # EKS Cluster, Node Group, Pod Identity, Access Entry
│   ├── database/                   # RDS MySQL, RDS Proxy, Read Replica
│   ├── elasticache/                # ElastiCache Redis / Replication Group
│   ├── sqs/                        # Booking Queue (Standard / FIFO) & DLQ
│   ├── ecr/                        # ECR Repository (Mutable / Immutable)
│   ├── secrets/                    # AWS Secrets Manager
│   ├── s3/                         # Poster Bucket & CloudFront CDN
│   ├── waf/                        # AWS WAF WebACL
│   ├── github_oidc/                # GitHub Actions OIDC IAM Role
│   └── monitoring/                 # KEDA / YACE / Cluster Autoscaler IRSA
│
└── envs/                           # 실제 실행 Root (환경별 분리)
    ├── dev/
    │   ├── infra/                  # dev AWS 인프라 리소스
    │   └── platform-addons/        # ArgoCD Bootstrap
    └── prod/
        ├── infra/                  # prod AWS 인프라 리소스
        └── platform-addons/        # ArgoCD Bootstrap
```

---

## ⚙️ 4. infra와 platform-addons 분리 사유

```text
Step 1: infra apply           (VPC, EKS, RDS, Redis, SQS, IAM 생성)
Step 2: platform-addons apply (ArgoCD, ESO, KEDA, Prometheus, LBC 설치)
```
- **문제 방지**: EKS Cluster가 생성되기 전 Helm/Kubernetes Provider가 EKS Endpoint에 접속을 시도하여 발생하는 초기화 에러(Race Condition)를 근본적으로 방지하기 위해 분리 적용.

---

## 🛡️ 5. 보안 및 운영 Hardening

1. **EKS Pod Identity & IAM Boundary**:
   - Node 전체 권한을 공유하지 않고 Pod 단위로 필요한 최소 IAM Role 부여.
   - IAM Role 상승을 방지하기 위한 `TeamRuntimeBoundary` 적용.
2. **SSM Session Manager Bastion**:
   - 22번 SSH 포트를 전면 차단하고, AWS SSM을 통한 세션 연결 구성.
   - 인스턴스 메타데이터 탈취 방지를 위한 IMDSv2 필수 적용.
3. **Secrets Manager & Random Password**:
   - RDS Master 패스워드 및 JWT Secret을 Terraform `random_password`로 생성하여 Secrets Manager에 암호화 저장.

---

## 🚀 6. Terraform CI/CD 파이프라인 (`.github/workflows/terraform.yml`)

```text
[Pull Request]
  └─► PR 생성 ──> Path Filter (dev/prod) ──> terraform fmt/validate ──> terraform plan ──> PR 코멘트 자동 작성

[Main Merge]
  ├─► dev/infra 변동 시 ──> terraform apply (자동 반영)
  └─► prod/infra 변동 시 ──> GitHub Environment 승인 게이트 ──> terraform apply (승인 후 반영)
```
- OIDC 기반 Trust Policy 적용 (`team5-gha-dev-role`, `team5-gha-prod-role`).

---

## 🛠️ 7. 실행 가이드라인

```powershell
# 1. State Backend 준비
cd bootstrap-backend
terraform init && terraform apply

# 2. Dev Infra 배포
cd ../envs/dev/infra
Copy-Item backend.tf.example backend.tf
terraform init && terraform apply

# 3. Dev Platform Add-ons 배포 (ArgoCD Bootstrap)
cd ../platform-addons
Copy-Item backend.tf.example backend.tf
terraform init && terraform apply
```
