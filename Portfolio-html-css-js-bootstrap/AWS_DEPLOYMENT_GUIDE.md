# AWS Deployment Guide for Portfolio Website

## 📋 Overview

This guide walks you through deploying your portfolio website on AWS using:
- **Terraform** - Infrastructure as Code (IaC)
- **Ansible** - Configuration Management
- **GitHub Actions** - CI/CD Pipeline

---

## 🔑 AWS Credentials Required

### Step 1: Create AWS IAM User

1. Go to [AWS Console](https://console.aws.amazon.com/)
2. Navigate to **IAM → Users → Create User**
3. User name: `portfolio-deployer`
4. **Do NOT** select "Provide user access to AWS Management Console"
5. Click **Next**

### Step 2: Set Permissions

1. Select "Attach policies directly"
2. Search for and attach these policies:
   - `AmazonEC2FullAccess`
   - `AmazonVPCFullAccess`
   - `AmazonS3FullAccess`
   - `IAMFullAccess` (for key pairs)

3. Click **Next → Create User**

### Step 3: Generate Access Keys

1. Click on the newly created user `portfolio-deployer`
2. Go to **Security Credentials** tab
3. Under "Access keys", click **Create access key**
4. Select **Command Line Interface (CLI)**
5. Accept the warning and click **Create access key**
6. **IMPORTANT**: Copy and save these immediately:
   ```
   Access Key ID: AKIA...
   Secret Access Key: xxxxxxxxxxxxxx
   ```
   ⚠️ **You won't see this secret again!**

---

## 🔐 SSH Key Pair Setup

### Step 1: Generate SSH Key (if you don't have one)

**On Windows (Git Bash or WSL):**
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

**On Mac/Linux:**
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

This creates:
- `~/.ssh/id_rsa` (private key - keep secret!)
- `~/.ssh/id_rsa.pub` (public key)

### Step 2: Get Your Public Key

```bash
cat ~/.ssh/id_rsa.pub
```

### Step 3: Get Your Private Key (for GitHub Secrets)

```bash
cat ~/.ssh/id_rsa
```

Copy the entire output including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`

---

## 📁 Project Structure

```
Portfolio-html-css-js-bootstrap/
├── terraform/
│   ├── main.tf                 # AWS infrastructure
│   ├── variables.tf            # Variables
│   ├── outputs.tf              # Output values
│   ├── user_data.sh            # EC2 bootstrap script
│   └── terraform.tfvars.example # Example config
├── ansible/
│   ├── deploy.yml              # Ansible playbook
│   ├── nginx.conf.j2           # Nginx template
│   └── hosts.ini               # Inventory file
├── .github/workflows/
│   └── deploy.yml              # GitHub Actions workflow
└── ...other portfolio files...
```

---

## 🔧 Local Setup (Before GitHub Actions)

### Step 1: Install Tools

**On Windows:**
```bash
# Install Terraform
choco install terraform

# Install Ansible
pip install ansible

# Install AWS CLI
choco install awscli
```

**On Mac:**
```bash
brew install terraform ansible awscli
```

**On Linux:**
```bash
sudo apt-get install terraform ansible awscli
```

### Step 2: Create terraform.tfvars

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
aws_region       = "us-east-1"        # Choose your region
instance_type    = "t2.micro"         # Free tier eligible
public_key_path  = "~/.ssh/id_rsa.pub"
github_repo_url  = "https://github.com/YOUR_USERNAME/Portfolio-html-css-js-bootstrap.git"
```

### Step 3: Configure AWS CLI

```bash
aws configure
```

Enter:
- AWS Access Key ID: `AKIA...`
- AWS Secret Access Key: `xxxx...`
- Default region: `us-east-1`
- Default output: `json`

### Step 4: Test Terraform

```bash
cd terraform
terraform init
terraform plan
```

---

## 🚀 GitHub Actions Setup

### Step 1: Fork the Repository (if not already)

Go to your portfolio repository on GitHub

### Step 2: Add GitHub Secrets

Go to **Settings → Secrets and variables → Actions → New repository secret**

Add these secrets:

| Secret Name | Value |
|------------|-------|
| `AWS_ACCESS_KEY_ID` | Your Access Key ID from IAM |
| `AWS_SECRET_ACCESS_KEY` | Your Secret Access Key from IAM |
| `AWS_REGION` | `us-east-1` (or your chosen region) |
| `SSH_PRIVATE_KEY` | Your complete `~/.ssh/id_rsa` file content |
| `GITHUB_REPO_URL` | `https://github.com/YOUR_USERNAME/Portfolio-html-css-js-bootstrap.git` |

**Example of adding SSH_PRIVATE_KEY:**
```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA1234567890...
...
-----END RSA PRIVATE KEY-----
```

### Step 3: Enable GitHub Actions

1. Go to **Actions** tab in your repository
2. Click "I understand my workflows, go ahead and enable them"

### Step 4: Deploy!

```bash
# Option 1: Push to main branch
git add .
git commit -m "Deploy portfolio to AWS"
git push origin main

# Option 2: Trigger manually from GitHub Actions tab
# Click "Run workflow" button
```

---

## 📊 What Gets Deployed

### AWS Resources Created:

1. **VPC** (Virtual Private Cloud)
   - Custom network isolated for your application

2. **EC2 Instance** (t2.micro - Free Tier)
   - Ubuntu 22.04 LTS
   - Nginx web server
   - Auto-configured with your website

3. **Security Group**
   - Port 80 (HTTP) - Open to world
   - Port 443 (HTTPS) - Open to world (for future SSL)
   - Port 22 (SSH) - Open (consider restricting to your IP)

4. **Elastic IP**
   - Static public IP address
   - You can access your site at: `http://YOUR_ELASTIC_IP`

5. **S3 Bucket** (for backups)
   - Backup storage

### After Deployment:

1. GitHub Actions will output your website URL
2. Access your site at: `http://<PUBLIC_IP>`
3. Nginx automatically serves your `index.html`

---

## 🌐 Access Your Deployed Website

After successful deployment:

1. Go to GitHub Actions → Latest workflow run
2. Find the deployment summary at the bottom
3. Click the link: **Website URL**

Or manually:
```bash
# Get public IP from Terraform output
cd terraform
terraform output instance_public_ip

# Access in browser
http://<PUBLIC_IP>
```

---

## 🛠️ Manual Commands (Alternative to GitHub Actions)

### Deploy Locally:

```bash
# 1. Initialize Terraform
cd terraform
terraform init

# 2. Plan infrastructure
terraform plan -var-file=terraform.tfvars

# 3. Apply (create AWS resources)
terraform apply -var-file=terraform.tfvars

# 4. Get the IP address
terraform output instance_public_ip

# 5. Update Ansible hosts file
cat > ../ansible/hosts.ini << 'EOF'
[portfolio_servers]
<PUBLIC_IP> ansible_user=ubuntu ansible_private_key_file=~/.ssh/id_rsa
EOF

# 6. Run Ansible playbook
cd ../ansible
ansible-playbook -i hosts.ini -e "github_repo_url=https://github.com/YOUR_USERNAME/Portfolio-html-css-js-bootstrap.git" deploy.yml

# 7. Verify
curl http://<PUBLIC_IP>
```

---

## 🧹 Cleanup (Destroy Infrastructure)

**⚠️ This will delete all AWS resources and stop charges**

```bash
cd terraform
terraform destroy -var-file=terraform.tfvars
```

Or via GitHub Actions: Add manual workflow trigger or modify workflow to destroy

---

## 🔒 Security Best Practices

1. **Restrict SSH Access**
   - Edit `terraform/main.tf`
   - Change SSH ingress CIDR from `0.0.0.0/0` to your IP:
   ```hcl
   cidr_blocks = ["YOUR_IP/32"]
   ```

2. **Use HTTPS**
   - Get free SSL via AWS Certificate Manager
   - Configure Nginx to use SSL
   - Update security group to allow port 443

3. **Rotate Keys Regularly**
   - Regenerate AWS IAM keys every 90 days
   - Update GitHub secrets

4. **Never Commit Secrets**
   - `.gitignore` includes `terraform.tfvars`
   - Never commit SSH private keys
   - Use GitHub Secrets for sensitive data

---

## 🐛 Troubleshooting

### "EC2 instance not ready"
```bash
# Wait longer before running Ansible
# Terraform output shows public IP
terraform output instance_public_ip

# SSH manually to test
ssh -i ~/.ssh/id_rsa ubuntu@<PUBLIC_IP>
```

### "Ansible playbook failed"
```bash
# Run with verbose output
ansible-playbook -i ansible/hosts.ini -v ansible/deploy.yml

# Check Nginx on instance
ssh -i ~/.ssh/id_rsa ubuntu@<PUBLIC_IP> "sudo systemctl status nginx"
```

### "Website returns 404"
```bash
# Check Nginx config
ssh -i ~/.ssh/id_rsa ubuntu@<PUBLIC_IP> "sudo nginx -t"

# Check website files exist
ssh -i ~/.ssh/id_rsa ubuntu@<PUBLIC_IP> "ls -la /var/www/portfolio/"
```

### GitHub Actions fails
1. Check **Actions → Latest run → Logs**
2. Verify all secrets are added correctly
3. Check IAM user permissions
4. Ensure SSH key is in correct format

---

## 📞 Quick Reference

### Important Values to Keep Safe:
```
AWS Account ID: (find in AWS console)
AWS Access Key ID: AKIA...
AWS Secret Access Key: xxxx... (KEEP SECRET!)
SSH Private Key: (keep in ~/.ssh/)
AWS Region: us-east-1
```

### Useful Commands:
```bash
# Check deployment status
aws ec2 describe-instances --region us-east-1

# Get public IP from AWS
aws ec2 describe-addresses --region us-east-1

# SSH to instance
ssh -i ~/.ssh/id_rsa ubuntu@<PUBLIC_IP>

# View Nginx logs
ssh -i ~/.ssh/id_rsa ubuntu@<PUBLIC_IP> "sudo tail -f /var/log/nginx/access.log"

# Restart Nginx
ssh -i ~/.ssh/id_rsa ubuntu@<PUBLIC_IP> "sudo systemctl restart nginx"
```

---

## 💰 AWS Free Tier Eligibility

- **EC2**: t2.micro up to 750 hours/month (first 12 months)
- **S3**: 5GB storage free
- **Data Transfer**: 1GB free/month
- **Elastic IP**: Free while attached to running instance

**Estimated Cost**: $0-3/month after free tier ends

---

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

## ✅ Deployment Checklist

- [ ] AWS IAM user created with access keys
- [ ] SSH keys generated
- [ ] GitHub repository forked/cloned
- [ ] GitHub secrets configured (5 secrets)
- [ ] `terraform.tfvars` created and updated
- [ ] `ansible/hosts.ini` updated
- [ ] GitHub Actions workflow enabled
- [ ] First deployment successful
- [ ] Website accessible at public IP
- [ ] DNS (optional): Point domain to Elastic IP

---

**Need help?** Check GitHub Issues or Terraform/Ansible documentation!
