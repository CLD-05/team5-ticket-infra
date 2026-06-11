#!/bin/bash

# ANSI Color Codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}          5팀 AWS 인프라 구축 검증 스크립트          ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. AWS 자격 증명 확인
echo -e "\n${YELLOW}[1/6] AWS STS 자격 증명 및 계정 확인${NC}"
aws sts get-caller-identity --output table
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✔ AWS CLI 연결 성공${NC}"
else
    echo -e "${RED}✘ AWS CLI 연결 실패. 자격 증명을 확인하세요.${NC}"
    exit 1
fi

# 2. VPC 및 서브넷 배치 확인
echo -e "\n${YELLOW}[2/6] VPC 및 서브넷 구성 확인${NC}"
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=team5-dev-vpc" --query "Vpcs[0].VpcId" --output text 2>/dev/null)
if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
    echo -e "${GREEN}✔ VPC 발견: $VPC_ID${NC}"
    echo -e "--- 서브넷 목록 ---"
    aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].[Tags[?Key=='Name'].Value | [0], CidrBlock, AvailabilityZone]" --output table
else
    echo -e "${RED}✘ team5-dev-vpc를 찾을 수 없습니다.${NC}"
fi

# 3. Bastion 호스트 상태 확인
echo -e "\n${YELLOW}[3/6] Bastion 호스트 가동 상태 확인${NC}"
BASTION_STATE=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=team5-dev-bastion" --query "Reservations[0].Instances[0].State.Name" --output text 2>/dev/null)
if [ "$BASTION_STATE" == "running" ]; then
    echo -e "${GREEN}✔ Bastion 호스트 가동 중 (running)${NC}"
else
    echo -e "${RED}✘ Bastion 호스트 상태: $BASTION_STATE (확인이 필요합니다)${NC}"
fi

# 4. 데이터베이스 및 메시징 자원 확인
echo -e "\n${YELLOW}[4/6] RDS, Redis, SQS 상태 확인${NC}"
# RDS Proxy
RDS_PROXY=$(aws rds describe-db-proxies --db-proxy-name team5-dev-rds-proxy --query "DBProxies[0].Status" --output text 2>/dev/null)
if [ "$RDS_PROXY" != "None" ] && [ -n "$RDS_PROXY" ]; then
    echo -e "RDS Proxy 상태: ${GREEN}$RDS_PROXY${NC}"
else
    echo -e "RDS Proxy 상태: ${RED}미발견 또는 생성 중${NC}"
fi

# Redis (ElastiCache)
REDIS_STATUS=$(aws elasticache describe-replication-groups --replication-group-id team5-dev-redis --query "ReplicationGroups[0].Status" --output text 2>/dev/null)
if [ "$REDIS_STATUS" != "None" ] && [ -n "$REDIS_STATUS" ]; then
    echo -e "Redis 복제그룹 상태: ${GREEN}$REDIS_STATUS${NC}"
else
    echo -e "Redis 복제그룹 상태: ${RED}미발견 또는 생성 중${NC}"
fi

# SQS Queue
SQS_URL=$(aws sqs get-queue-url --queue-name team5-dev-booking-queue --query "QueueUrl" --output text 2>/dev/null)
if [ "$SQS_URL" != "None" ] && [ -n "$SQS_URL" ]; then
    echo -e "SQS 큐 발견: ${GREEN}$SQS_URL${NC}"
else
    echo -e "${RED}✘ SQS 큐를 찾을 수 없습니다.${NC}"
fi

# 5. EKS 클러스터 및 노드 그룹 확인
echo -e "\n${YELLOW}[5/6] EKS 클러스터 및 노드 그룹 상태 확인${NC}"
EKS_STATUS=$(aws eks describe-cluster --name team5-dev-eks --query "cluster.status" --output text 2>/dev/null)
if [ "$EKS_STATUS" != "None" ] && [ -n "$EKS_STATUS" ]; then
    echo -e "EKS 클러스터 상태: ${GREEN}$EKS_STATUS${NC}"
else
    echo -e "EKS 클러스터 상태: ${RED}미발견 또는 생성 중${NC}"
fi

NG_STATUS=$(aws eks describe-nodegroup --cluster-name team5-dev-eks --nodegroup-name team5-dev-eks-app-ng --query "nodegroup.status" --output text 2>/dev/null)
if [ "$NG_STATUS" != "None" ] && [ -n "$NG_STATUS" ]; then
    echo -e "노드 그룹 (team5-dev-eks-app-ng) 상태: ${GREEN}$NG_STATUS${NC}"
else
    echo -e "노드 그룹 상태: ${RED}미발견 또는 생성 중${NC}"
fi

# 6. Kubernetes 리소스 및 플랫폼 애드온 상태 확인 (kubectl)
echo -e "\n${YELLOW}[6/6] Kubernetes 플랫폼 애드온 및 포드(Pod) 확인${NC}"
kubectl cluster-info >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✔ Kubernetes 클러스터 연결 성공${NC}"
    
    echo -e "\n--- 가동 중인 Namespaces ---"
    kubectl get ns
    
    echo -e "\n--- 플랫폼 애드온 Pods 상태 ---"
    kubectl get pods -A -o wide
    
    echo -e "\n--- EKS Worker Nodes 목록 ---"
    kubectl get nodes -o wide
else
    echo -e "${RED}✘ Kubernetes 클러스터(kubectl)에 연결할 수 없습니다. kubeconfig 설정을 확인하세요.${NC}"
fi

echo -e "\n${BLUE}====================================================${NC}"
echo -e "${GREEN}             검증 스크립트 실행 완료!             ${NC}"
echo -e "${BLUE}====================================================${NC}"
