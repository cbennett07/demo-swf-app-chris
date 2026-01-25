#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}  Demo SWF App Chris - AWS Fargate Deployment${NC}"
echo -e "${GREEN}==================================================${NC}"

# Check prerequisites
echo -e "\n${YELLOW}Checking prerequisites...${NC}"

if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Terraform is not installed. Please install it first.${NC}"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install it first.${NC}"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}AWS credentials not configured. Run 'aws configure' first.${NC}"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(grep 'aws_region' terraform.tfvars | cut -d'"' -f2)
PROJECT_NAME=$(grep 'project_name' terraform.tfvars | cut -d'"' -f2)

echo -e "${GREEN}AWS Account: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${GREEN}Region: ${AWS_REGION}${NC}"
echo -e "${GREEN}Project: ${PROJECT_NAME}${NC}"

# Step 1: Initialize and apply Terraform
echo -e "\n${YELLOW}Step 1: Initializing Terraform...${NC}"
terraform init

echo -e "\n${YELLOW}Step 2: Planning infrastructure changes...${NC}"
terraform plan -out=tfplan

echo -e "\n${YELLOW}Step 3: Applying infrastructure (this may take 10-15 minutes)...${NC}"
read -p "Continue with apply? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    terraform apply tfplan
else
    echo -e "${YELLOW}Skipping terraform apply${NC}"
fi

# Get ECR URL
ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null || echo "")

if [ -z "$ECR_URL" ]; then
    echo -e "${RED}Could not get ECR URL. Make sure Terraform applied successfully.${NC}"
    exit 1
fi

# Step 4: Build and push Docker image
echo -e "\n${YELLOW}Step 4: Building Docker image...${NC}"
cd ..
docker build -t ${PROJECT_NAME}:latest .

echo -e "\n${YELLOW}Step 5: Logging into ECR...${NC}"
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}

echo -e "\n${YELLOW}Step 6: Tagging and pushing image to ECR...${NC}"
docker tag ${PROJECT_NAME}:latest ${ECR_URL}:latest
docker push ${ECR_URL}:latest

# Step 7: Force new deployment
echo -e "\n${YELLOW}Step 7: Forcing new ECS deployment...${NC}"
cd terraform
ECS_CLUSTER=$(terraform output -raw ecs_cluster_name)
ECS_SERVICE=$(terraform output -raw ecs_service_name)
aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --force-new-deployment --region ${AWS_REGION}

echo -e "\n${GREEN}==================================================${NC}"
echo -e "${GREEN}  Deployment initiated!${NC}"
echo -e "${GREEN}==================================================${NC}"

echo -e "\n${YELLOW}Important next steps:${NC}"
echo -e "1. Check ACM certificate validation status:"
echo -e "   ${GREEN}terraform output acm_validation_records${NC}"
echo -e "   Add these CNAME records to Cloudflare"
echo -e ""
echo -e "2. After certificate is validated, add Cloudflare DNS:"
echo -e "   ${GREEN}terraform output cloudflare_dns_instructions${NC}"
echo -e ""
echo -e "3. Monitor ECS service deployment:"
echo -e "   ${GREEN}aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${ECS_SERVICE} --region ${AWS_REGION}${NC}"
echo -e ""
echo -e "4. View application logs:"
echo -e "   ${GREEN}aws logs tail /ecs/${PROJECT_NAME} --follow --region ${AWS_REGION}${NC}"
echo -e ""
echo -e "5. Application URL (after DNS propagation):"
echo -e "   ${GREEN}$(terraform output -raw application_url)${NC}"
