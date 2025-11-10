# 🔐 AWS Deployment Credentials Checklist

## ⚠️ KEEP THIS SAFE - DO NOT COMMIT TO GIT!

### Step 1: AWS IAM Credentials ✅

Go to [AWS Console](https://console.aws.amazon.com/) → IAM → Users

**Create IAM User:**
- Username: `portfolio-deployer`
- Permissions needed:
  - [ ] AmazonEC2FullAccess
  - [ ] AmazonVPCFullAccess
  - [ ] AmazonS3FullAccess
  - [ ] IAMFullAccess

**Save these values immediately (you won't see them again):**

```
AWS_ACCESS_KEY_ID: 
AKIA____________________________

AWS_SECRET_ACCESS_KEY: 
____________________________

AWS_REGION: 
us-east-1
```

---

### Step 2: SSH Key Pair 🔑

**Generate if you don't have one:**
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

**Save your keys:**

```
SSH Public Key (~/.ssh/id_rsa.pub):
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB...
```

```
SSH Private Key (~/.ssh/id_rsa):
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA1234567890...
[entire key content]
-----END RSA PRIVATE KEY-----
```

---

### Step 3: GitHub Configuration 🐙

**Repository URL:**
```
https://github.com/YOUR_USERNAME/Portfolio-html-css-js-bootstrap.git
```

**GitHub Personal Access Token (Optional, for private repos):**
```
ghp_____________________________
```

---

### Step 4: GitHub Secrets Setup 🔒

Go to: Settings → Secrets and variables → Actions → New repository secret

| Secret Name | Value | Where to Find |
|------------|-------|----------------|
| `AWS_ACCESS_KEY_ID` | `AKIA...` | From Step 1 above |
| `AWS_SECRET_ACCESS_KEY` | `xxxx...` | From Step 1 above |
| `AWS_REGION` | `us-east-1` | Your choice |
| `SSH_PRIVATE_KEY` | Full private key content | From Step 2 above |
| `GITHUB_REPO_URL` | GitHub HTTPS URL | From Step 3 above |

**Paste exactly like this (including -----BEGIN-----/-----END-----):**
```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
(entire key)
-----END RSA PRIVATE KEY-----
```

---

### Step 5: Create terraform.tfvars 📝

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
aws_region       = "us-east-1"
instance_type    = "t2.micro"
public_key_path  = "~/.ssh/id_rsa.pub"
github_repo_url  = "https://github.com/YOUR_USERNAME/Portfolio-html-css-js-bootstrap.git"
```

---

## 🚀 Quick Start

### Option A: Automatic Deployment (Recommended)

```bash
chmod +x deploy.sh
./deploy.sh
```

Follow the prompts!

### Option B: Manual Deployment

```bash
# 1. Configure AWS
aws configure
# Enter your access key and secret key

# 2. Deploy
cd terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

# 3. Get IP
PUBLIC_IP=$(terraform output -raw instance_public_ip)
echo $PUBLIC_IP

# 4. Update Ansible inventory
cd ../ansible
echo "[portfolio_servers]
$PUBLIC_IP ansible_user=ubuntu ansible_private_key_file=~/.ssh/id_rsa" > hosts.ini

# 5. Run Ansible
ansible-playbook -i hosts.ini \
  -e "github_repo_url=https://github.com/YOUR_USERNAME/Portfolio-html-css-js-bootstrap.git" \
  deploy.yml

# 6. Access
echo "Visit: http://$PUBLIC_IP"
```

---

## 📋 Summary Table

| What | Where | Example |
|-----|-------|---------|
| AWS Access Key | GitHub Secrets | AKIA2345... |
| AWS Secret Key | GitHub Secrets | wJalrXUtnFEMI/K7MDENG... |
| AWS Region | terraform.tfvars | us-east-1 |
| SSH Private Key | GitHub Secrets | (full key with -----BEGIN-----) |
| GitHub Repo URL | terraform.tfvars | https://github.com/user/repo.git |
| EC2 Public IP | Terraform Output | 203.0.113.45 |
| Website URL | After Deploy | http://203.0.113.45 |

---

## ⚠️ Security Reminders

1. **Never commit `terraform.tfvars`** - It's in `.gitignore`
2. **Never commit SSH keys** - It's in `.gitignore`
3. **Regenerate IAM keys yearly** - Then update GitHub secrets
4. **Use GitHub Secrets** - Not hardcoded in workflows
5. **Restrict SSH access** - Edit `terraform/main.tf` to limit IPs
6. **Enable CloudTrail** - Monitor AWS activity
7. **Set IAM policy limits** - Only give needed permissions

---

## 🧹 Cleanup

**To delete all AWS resources and stop billing:**

```bash
cd terraform
terraform destroy -var-file=terraform.tfvars
```

Type `yes` when prompted.

---

## 💬 Support

Check these files for more help:
- `AWS_DEPLOYMENT_GUIDE.md` - Full deployment guide
- `terraform/main.tf` - Infrastructure code
- `ansible/deploy.yml` - Deployment configuration
- `.github/workflows/deploy.yml` - GitHub Actions

---

**Last Updated:** November 2024
