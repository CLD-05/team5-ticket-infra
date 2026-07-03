# Team5 Ticket Infrastructure

## 1. Overview

이 저장소는 Team5 티켓팅 플랫폼의 AWS 인프라를 Terraform으로 관리하는 IaC 저장소입니다.

티켓팅 서비스는 특정 시간에 트래픽이 급격히 몰리는 특성이 있으므로, 단순한 서버 배포가 아니라 트래픽 완충, 비동기 처리, 데이터 정합성, 오토스케일링, 운영 관측성을 함께 고려해야 합니다.

이를 위해 본 인프라는 아래 목표를 기준으로 설계했습니다.

### 주요 목표

- EKS 기반 애플리케이션 실행 환경 구성
- RDS, Redis, SQS를 활용한 예매 처리 안정성 확보
- dev/prod 환경 분리
- Terraform 기반 인프라 형상 관리
- GitHub Actions OIDC 기반 Terraform CI/CD 구성
- ArgoCD 기반 GitOps 배포 구조 지원
- 운영 환경 기준 고가용성, 보안, 관측성 확장 가능 구조 확보

---

## 2. Architecture

전체 구조는 AWS 위에 EKS를 중심으로 구성되어 있습니다.

```text
(아키텍처 이미지 첨부 예정)
```

### 핵심 설계 방향

- Web API Pod와 Booking Worker Pod를 분리하여 요청 처리와 예매 확정 처리를 분리
- SQS를 통해 예매 확정 요청을 비동기 처리하여 DB 부하 완화
- Redis를 사용해 대기열, 좌석 선점, 동시성 제어를 처리
- RDS Proxy를 통해 DB Connection Pool 압박 완화
- Secrets Manager와 External Secrets Operator를 사용해 애플리케이션 설정을 Kubernetes Secret으로 동기화
- ArgoCD를 통해 Kubernetes Manifest를 GitOps 방식으로 적용
- prod 환경은 3AZ, Multi NAT, Multi-AZ RDS/Redis 기반으로 고가용성 방향 적용

---

## 3. Repository Structure

```text
team5-ticket-infra/
├── bootstrap-backend/
│   └── Terraform state backend용 S3 bucket 생성
│
├── modules/
│   ├── network/        # VPC, Subnet, NAT, Routing
│   ├── bastion/        # SSM Bastion
│   ├── eks/            # EKS Cluster, Node Group, IRSA
│   ├── database/       # RDS MySQL, RDS Proxy, Read Replica
│   ├── elasticache/    # Redis
│   ├── sqs/            # Booking Queue, DLQ
│   ├── ecr/            # ECR Repository
│   ├── secrets/        # Secrets Manager
│   ├── s3/             # Poster Image Bucket, CloudFront
│   ├── monitoring/     # KEDA / YACE / Cluster Autoscaler IAM
│   ├── waf/            # AWS WAF
│   └── github_oidc/    # GitHub Actions OIDC Role
│
└── envs/
    ├── dev/
    │   ├── infra/
    │   └── platform-addons/
    │
    └── prod/
        ├── infra/
        └── platform-addons/
```

Repository는 `modules`와 `envs`로 분리되어 관리됩니다.

| Directory | Description |
|-----------|-------------|
| `modules` | 재사용 가능한 Terraform Module |
| `envs/dev` | 개발 및 통합 검증 환경 |
| `envs/prod` | 운영 환경 |
| `platform-addons` | ArgoCD Bootstrap 및 Kubernetes Provider 기반 리소스 |

---

## 4. Environment

### dev

개발 및 통합 검증을 위한 비용 효율 중심 환경입니다.

- 빠른 검증과 비용 절감 우선
- prod와 동일한 서비스 흐름 유지
- RDS, Redis, SQS, ECR, Secrets Manager, EKS 구성

### prod

운영 환경 기준으로 구성됩니다.

- 고가용성 및 안정성 우선
- EKS Private Endpoint 사용
- Bastion/SSM 기반 클러스터 접근

---

## 5. Infrastructure Components

### Network

VPC는 Public, Private, Database Subnet으로 분리합니다.

**Public Subnet**

- ALB
- NAT Gateway
- Bastion

**Private Subnet**

- EKS Worker Node

**Database Subnet**

- RDS
- Redis

dev는 Single NAT를, prod는 Multi NAT를 사용합니다.

---

### Compute

애플리케이션은 EKS에서 실행됩니다.

- EKS Node Group 구성
- Kubernetes Add-on 및 Application Manifest는 ArgoCD 관리
- prod는 Private Endpoint 사용

---

### Database

RDS MySQL은 최종 예매 데이터의 정합성을 담당합니다.

- RDS Proxy를 통한 Connection 관리
- prod Multi-AZ
- prod Read Replica
- Terraform Random Password 생성
- Secrets Manager 연동

---

### Cache

Redis는 티켓팅 서비스의 동시성 제어에 사용됩니다.

주요 사용처

- 대기열
- Queue Token
- 좌석 임시 선점
- Redisson 기반 분산 락

prod에서는 Redis Replication Group을 사용합니다.

---

### Messaging

SQS는 예매 확정 요청을 비동기로 처리하기 위한 메시징 계층입니다.

처리 흐름

```text
Web API
    ↓
SQS
    ↓
Worker Pod
    ↓
RDS
```

---

### Security & Secrets

애플리케이션 런타임 설정은 AWS Secrets Manager에 저장합니다.

- External Secrets Operator를 통한 Kubernetes Secret 동기화
- GitHub OIDC 기반 IAM Role Assume 방식 사용
- AWS Access Key 미사용

---

### Observability & Autoscaling

지원 구성

- Prometheus
- Grafana
- KEDA
- Cluster Autoscaler
- YACE
- CloudWatch
- WAF Logging

Terraform은 IAM/IRSA를 관리하며, 실제 Add-on 설치는 Config Repository와 ArgoCD가 담당합니다.

---

## 6. Deployment

### Core Infra

`envs/{env}/infra`

생성 대상

- VPC
- EKS
- Bastion
- RDS
- Redis
- SQS
- ECR
- Secrets Manager
- S3 / CloudFront
- WAF / Route53
- GitHub OIDC Role
- Monitoring IRSA

---

### Platform Add-ons

`envs/{env}/platform-addons`

ArgoCD Bootstrap을 담당합니다.

Repository 역할은 다음과 같습니다.

```text
infra repo
    ↓
AWS Infrastructure
ArgoCD Bootstrap

config repo
    ↓
Kubernetes Add-on
Application Manifest

app repo
    ↓
Application Source
Docker Build
ECR Push
```

Terraform과 ArgoCD의 관리 영역을 분리하여 동일 리소스를 중복 관리하지 않습니다.

---

## 7. CI/CD

Workflow

```text
.github/workflows/terraform.yml
```

### Pull Request

```text
PR
 ↓
Changed Path Detection
 ↓
terraform fmt
 ↓
terraform init
 ↓
terraform validate
 ↓
terraform plan
 ↓
PR Comment
```

Plan 대상

- `envs/dev/infra`
- `envs/prod/infra`

---

### Main Merge

```text
dev infra
    ↓
Auto Apply

prod infra
    ↓
GitHub Environment Approval
    ↓
Apply
```

---

### tfvars

GitHub Secrets

```text
DEV_TERRAFORM_TFVARS
PROD_TERRAFORM_TFVARS
```

`terraform.tfvars`는 Git에 커밋하지 않습니다.

---

## 8. Operations

운영 시 주요 확인 사항

- Terraform Plan 변경 사항 확인
- EKS Node Group 상태 확인
- RDS / Redis / SQS / ECR / Secrets Manager Output 확인
- External Secrets 동기화 확인
- ArgoCD Application Sync 상태 확인
- KEDA / Cluster Autoscaler / Prometheus Add-on 상태 확인

prod는 Private Endpoint를 사용하므로 Bastion/SSM을 통한 접근을 전제로 합니다.
