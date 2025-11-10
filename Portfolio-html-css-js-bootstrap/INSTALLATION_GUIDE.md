# 🛠️ Installation & Prerequisites Guide

## System Requirements

- Operating System: Windows, Mac, or Linux
- Internet Connection: Stable
- Free AWS Account (with credit card for verification)
- GitHub Account (free)

## ⚙️ Required Tools

### 1. Git
**For managing your code**

**Windows:**
```bash
choco install git
```

**Mac:**
```bash
brew install git
```

**Linux:**
```bash
sudo apt-get install git
```

**Verify:**
```bash
git --version
```

---

### 2. Terraform
**For Infrastructure as Code**

**Windows:**
```bash
choco install terraform
```

**Mac:**
```bash
brew install terraform
```

**Linux:**
```bash
# Download from terraform.io/downloads or:
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

**Verify:**
```bash
terraform version
```

---

### 3. AWS CLI
**For managing AWS from command line**

**Windows:**
```bash
choco install awscli
```

**Mac:**
```bash
brew install awscli
```

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Verify:**
```bash
aws --version
```

---

### 4. Python & Pip
**For Ansible and other tools**

**Windows:**
```bash
choco install python
```

**Mac:**
```bash
brew install python
```

**Linux:**
```bash
sudo apt-get install python3 python3-pip
```

**Verify:**
```bash
python --version
pip --version
```

---

### 5. Ansible
**For Configuration Management**

```bash
pip install ansible
```

Or with requirements file (in project directory):
```bash
pip install -r requirements.txt
```

**Verify:**
```bash
ansible --version
```

---

### 6. SSH (for key generation)

**Windows:**
- Included in Git Bash (installed with Git)
- Or: `choco install openssh`

**Mac & Linux:**
- Usually pre-installed

**Verify:**
```bash
ssh -V
```

---

## 🔑 Generate SSH Keys (One-time)

**Generate if you don't have keys:**

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

**Expected output:**
```
Generating public/private rsa key pair.
Your identification has been saved in ~/.ssh/id_rsa.
Your public key has been saved in ~/.ssh/id_rsa.pub.
```

**Verify your keys:**
```bash
ls -la ~/.ssh/
# Should show:
# id_rsa (private key)
# id_rsa.pub (public key)
```

---

## 📦 Python Dependencies

Install all at once:

```bash
pip install -r requirements.txt
```

Or individually:

```bash
pip install ansible
pip install boto3
pip install botocore
pip install awscli
```

---

## 🔐 AWS CLI Configuration

```bash
aws configure
```

Enter when prompted:
```
AWS Access Key ID: AKIA...
AWS Secret Access Key: xxxx...
Default region name: us-east-1
Default output format: json
```

**Verify:**
```bash
aws s3 ls
# Should list your S3 buckets (or show empty if none exist)
```

---

## 📋 Complete Installation Script

### For Mac/Linux:

```bash
#!/bin/bash

# Install Homebrew (Mac only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install tools
brew install terraform awscli python git ansible

# Generate SSH keys
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Install Python dependencies
pip install -r requirements.txt

# Verify installations
echo "=== Verification ==="
terraform version
aws --version
python --version
ansible --version
ssh -V
```

### For Windows (in PowerShell as Admin):

```powershell
# Install Chocolatey (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install tools
choco install -y git terraform awscli python ansible

# Generate SSH keys (in Git Bash)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Install Python dependencies
pip install -r requirements.txt

# Verify
terraform version
aws --version
python --version
ansible --version
```

---

## ✅ Verification Checklist

Run these commands to verify everything is installed:

```bash
# Git
git --version
# Expected: git version 2.x.x

# Terraform
terraform version
# Expected: Terraform v1.x.x

# AWS CLI
aws --version
# Expected: aws-cli/2.x.x Python/3.x.x

# Python
python --version
# Expected: Python 3.x.x

# Ansible
ansible --version
# Expected: ansible [core 2.x.x]

# SSH
ssh -V
# Expected: OpenSSH_x.x version

# SSH Keys
ls ~/.ssh/id_rsa*
# Expected: id_rsa and id_rsa.pub files
```

---

## 🚀 You're Ready!

Once all tools are installed and verified:

1. Navigate to project directory:
```bash
cd Portfolio-html-css-js-bootstrap
```

2. Choose your deployment method:
```bash
# Option 1: Automatic
./deploy.sh

# Option 2: Manual
cd terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

---

## 🆘 Common Issues

### "Command not found: terraform"
- Verify Terraform is in PATH
- Windows: Restart terminal after installation
- Mac/Linux: Add to PATH if needed

### "pip: command not found"
- Python not installed or not in PATH
- Windows: Reinstall Python, check "Add Python to PATH" during installation

### "Permission denied: ./deploy.sh"
```bash
chmod +x deploy.sh
./deploy.sh
```

### "SSH key permission too open"
```bash
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

### "aws configure" not working
- Reinstall AWS CLI: `pip install --upgrade awscli`
- Verify Python is installed: `python --version`

---

## 📚 Optional Tools (For Advanced Users)

### For Better Development Experience:

**VS Code Extensions:**
- HashiCorp Terraform
- Ansible
- AWS Toolkit

**Command-line Tools:**
```bash
# For better terminal (Windows)
choco install windows-terminal

# For better shell (All platforms)
brew install zsh  # Mac
sudo apt-get install zsh  # Linux

# For terminal productivity (All platforms)
pip install awscli-local  # Local AWS
brew install direnv  # Environment management
```

---

## 💾 Installation Locations

**Terraform:**
- Windows: `C:\Program Files\HashiCorp\Terraform\`
- Mac: `/usr/local/bin/terraform`
- Linux: `/usr/local/bin/terraform`

**AWS CLI:**
- Windows: `C:\Program Files\Amazon\AWSCLI\`
- Mac: `/usr/local/bin/aws`
- Linux: `/usr/local/bin/aws`

**Python (for Ansible):**
- Windows: `C:\Python3X\`
- Mac: `/usr/local/opt/python@3.x/`
- Linux: `/usr/bin/python3`

**SSH Keys:**
- All platforms: `~/.ssh/` (home directory)

---

## ⏱️ Installation Time

| Tool | Time |
|------|------|
| Git | 2 min |
| Terraform | 2 min |
| AWS CLI | 2 min |
| Python | 5 min |
| Ansible | 2 min |
| SSH Keys | 1 min |
| **Total** | **~15 min** |

---

## 🎯 Next Steps

1. Complete all installations (15 min)
2. Verify all tools work (5 min)
3. Generate SSH keys (1 min)
4. Configure AWS CLI (5 min)
5. Read deployment guide (5 min)
6. Run deployment (10-15 min)

**Total time to live website: ~50 minutes**

---

## 📞 Need Help?

1. Check tool's official documentation
2. Run `<tool> --help` for usage
3. Run `<tool> --version` to verify installation
4. See troubleshooting guides in main documentation

---

**Installation complete? Read: [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) next!**
