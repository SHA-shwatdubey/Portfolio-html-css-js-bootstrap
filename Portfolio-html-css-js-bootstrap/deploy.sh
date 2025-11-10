#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Portfolio AWS Deployment Script ===${NC}\n"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Terraform installed$(NC)"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ AWS CLI installed${NC}"

# Check SSH key
if [ ! -f ~/.ssh/id_rsa ]; then
    echo -e "${YELLOW}SSH key not found. Creating...${NC}"
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo -e "${GREEN}✓ SSH key created${NC}"
else
    echo -e "${GREEN}✓ SSH key exists${NC}"
fi

echo ""

# Read configuration
echo -e "${BLUE}=== Configuration ===${NC}\n"

read -p "Enter AWS Region (default: us-east-1): " AWS_REGION
AWS_REGION=${AWS_REGION:-us-east-1}

read -p "Enter GitHub username: " GITHUB_USERNAME
read -p "Enter repository name (default: Portfolio-html-css-js-bootstrap): " REPO_NAME
REPO_NAME=${REPO_NAME:-Portfolio-html-css-js-bootstrap}

GITHUB_REPO_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

echo ""
echo -e "${YELLOW}Configuration Summary:${NC}"
echo "  AWS Region: ${AWS_REGION}"
echo "  GitHub URL: ${GITHUB_REPO_URL}"
echo ""

# Create terraform.tfvars
echo -e "${YELLOW}Creating terraform.tfvars...${NC}"

cat > terraform/terraform.tfvars << EOF
aws_region       = "${AWS_REGION}"
instance_type    = "t2.micro"
public_key_path  = "~/.ssh/id_rsa.pub"
github_repo_url  = "${GITHUB_REPO_URL}"
EOF

echo -e "${GREEN}✓ terraform.tfvars created${NC}\n"

# Initialize Terraform
echo -e "${YELLOW}Initializing Terraform...${NC}"
cd terraform
terraform init

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Terraform init failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Terraform initialized${NC}\n"

# Plan
echo -e "${YELLOW}Planning Terraform changes...${NC}"
terraform plan -var-file=terraform.tfvars -out=tfplan

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Terraform plan failed${NC}"
    exit 1
fi

echo ""
read -p "Do you want to apply these changes? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Deployment cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}Applying Terraform...${NC}"
terraform apply -auto-approve tfplan

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Terraform apply failed${NC}"
    exit 1
fi

echo ""
PUBLIC_IP=$(terraform output -raw instance_public_ip)
echo -e "${GREEN}✓ Infrastructure created!${NC}"
echo -e "${BLUE}Public IP: ${PUBLIC_IP}${NC}\n"

# Create Ansible inventory
echo -e "${YELLOW}Creating Ansible inventory...${NC}"
cd ../ansible

cat > hosts.ini << EOF
[portfolio_servers]
${PUBLIC_IP} ansible_user=ubuntu ansible_private_key_file=~/.ssh/id_rsa
EOF

echo -e "${GREEN}✓ Ansible inventory created${NC}\n"

# Wait for EC2
echo -e "${YELLOW}Waiting for EC2 instance to be ready (timeout: 180s)...${NC}"
timeout 180 bash -c "until ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o ConnectTimeout=5 ubuntu@${PUBLIC_IP} 'echo ready' > /dev/null 2>&1; do echo -n '.'; sleep 10; done"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ EC2 instance failed to become ready${NC}"
    echo -e "${YELLOW}You can try manually running Ansible:${NC}"
    echo "ansible-playbook -i ansible/hosts.ini -e \"github_repo_url=${GITHUB_REPO_URL}\" ansible/deploy.yml"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ EC2 instance ready${NC}\n"

# Run Ansible
echo -e "${YELLOW}Running Ansible playbook...${NC}"
ansible-playbook -i hosts.ini -e "github_repo_url=${GITHUB_REPO_URL}" deploy.yml

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ansible playbook failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Ansible deployment complete${NC}\n"

# Verify
echo -e "${YELLOW}Verifying website...${NC}"
sleep 5
curl -f "http://${PUBLIC_IP}/" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Website is live!${NC}\n"
else
    echo -e "${YELLOW}⚠ Could not verify website, but deployment may have succeeded${NC}\n"
fi

echo -e "${BLUE}=== Deployment Complete ===${NC}\n"
echo -e "${GREEN}Your portfolio is live at:${NC}"
echo -e "${BLUE}http://${PUBLIC_IP}${NC}\n"

echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update your domain DNS to point to: ${PUBLIC_IP}"
echo "2. Set up GitHub secrets for automated deployments"
echo "3. Read AWS_DEPLOYMENT_GUIDE.md for more details\n"

echo -e "${YELLOW}To tear down infrastructure:${NC}"
echo "  cd terraform && terraform destroy -var-file=terraform.tfvars\n"
