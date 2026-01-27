#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}  Demo SWF App Chris - Azure Container Apps Deploy ${NC}"
echo -e "${GREEN}==================================================${NC}"

# Check prerequisites
echo -e "\n${YELLOW}Checking prerequisites...${NC}"

if ! command -v az &> /dev/null; then
    echo -e "${RED}Azure CLI is not installed. Please install it first.${NC}"
    echo -e "${RED}  brew install azure-cli  (macOS)${NC}"
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

# Check Azure login
if ! az account show &> /dev/null; then
    echo -e "${RED}Not logged into Azure. Run 'az login' first.${NC}"
    exit 1
fi

AZURE_SUBSCRIPTION=$(az account show --query name --output tsv)
AZURE_SUBSCRIPTION_ID=$(az account show --query id --output tsv)
PROJECT_NAME=$(grep 'project_name' terraform.tfvars | cut -d'"' -f2)

echo -e "${GREEN}Azure Subscription: ${AZURE_SUBSCRIPTION}${NC}"
echo -e "${GREEN}Subscription ID: ${AZURE_SUBSCRIPTION_ID}${NC}"
echo -e "${GREEN}Project: ${PROJECT_NAME}${NC}"

# Step 1: Initialize Terraform
echo -e "\n${YELLOW}Step 1: Initializing Terraform...${NC}"
terraform init

# Step 2: Plan
echo -e "\n${YELLOW}Step 2: Planning infrastructure changes...${NC}"
terraform plan -out=tfplan

# Step 3: Apply
echo -e "\n${YELLOW}Step 3: Applying infrastructure...${NC}"
read -p "Continue with apply? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    terraform apply tfplan
else
    echo -e "${YELLOW}Skipping terraform apply${NC}"
fi

# Get outputs
ACR_NAME=$(terraform output -raw acr_name 2>/dev/null || echo "")
ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server 2>/dev/null || echo "")

if [ -z "$ACR_LOGIN_SERVER" ]; then
    echo -e "${RED}Could not get ACR login server. Make sure Terraform applied successfully.${NC}"
    exit 1
fi

RESOURCE_GROUP=$(terraform output -raw resource_group_name)
CONTAINER_APP_NAME=$(terraform output -raw container_app_name)

# Step 4: Build Docker image
echo -e "\n${YELLOW}Step 4: Building Docker image...${NC}"
cd ..
docker build -t ${PROJECT_NAME}:latest .

# Step 5: Login to ACR
echo -e "\n${YELLOW}Step 5: Logging into Azure Container Registry...${NC}"
az acr login --name ${ACR_NAME}

# Step 6: Tag and push image
echo -e "\n${YELLOW}Step 6: Tagging and pushing image to ACR...${NC}"
docker tag ${PROJECT_NAME}:latest ${ACR_LOGIN_SERVER}/${PROJECT_NAME}:latest
docker push ${ACR_LOGIN_SERVER}/${PROJECT_NAME}:latest

# Step 7: Update Container App
echo -e "\n${YELLOW}Step 7: Updating Container App with new image...${NC}"
cd terraform-azure
az containerapp update \
    --name ${CONTAINER_APP_NAME} \
    --resource-group ${RESOURCE_GROUP} \
    --image ${ACR_LOGIN_SERVER}/${PROJECT_NAME}:latest

echo -e "\n${GREEN}==================================================${NC}"
echo -e "${GREEN}  Deployment complete!${NC}"
echo -e "${GREEN}==================================================${NC}"

echo -e "\n${YELLOW}Application details:${NC}"
echo -e "1. Application URL:"
echo -e "   ${GREEN}$(terraform output -raw application_url)${NC}"
echo -e ""
echo -e "2. Health check URL:"
echo -e "   ${GREEN}$(terraform output -raw health_check_url)${NC}"
echo -e ""
echo -e "3. View application logs:"
echo -e "   ${GREEN}$(terraform output -raw container_app_logs_command)${NC}"
echo -e ""
echo -e "4. Monitor in Azure Portal:"
echo -e "   ${GREEN}https://portal.azure.com/#@/resource/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.App/containerApps/${CONTAINER_APP_NAME}/overview${NC}"
