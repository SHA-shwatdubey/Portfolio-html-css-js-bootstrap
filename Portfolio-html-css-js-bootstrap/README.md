# Portfolio-html-css-js-bootstrap

A responsive portfolio website built with HTML, CSS, JavaScript, and Bootstrap.

## 🚀 Quick Start (Local)

1. Clone the repository:
```bash
git clone https://github.com/SHA-shwatdubey/Portfolio-html-css-js-bootstrap.git
cd Portfolio-html-css-js-bootstrap
```

2. Open in browser:
```bash
# Using Python (any version)
python -m http.server 8000

# Or with Node.js (if installed)
npx http-server

# Or simply open index.html in your browser
```

3. Visit: `http://localhost:8000`

---

## ☁️ Deploy to AWS with Terraform + Ansible + GitHub Actions

### 📋 Prerequisites

- AWS Account (free tier eligible)
- GitHub Account
- SSH Key Pair
- Git

### 🔑 Credentials Needed

1. **AWS IAM Access Keys** (Create a new IAM user)
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

2. **SSH Key Pair** (Generate or use existing)
   - SSH Private Key
   - SSH Public Key

3. **GitHub Secrets** (5 total)
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `SSH_PRIVATE_KEY`
   - `GITHUB_REPO_URL`

### 🚀 Deployment Methods

#### Method 1: Automatic (Recommended)
```bash
chmod +x deploy.sh
./deploy.sh
```

#### Method 2: GitHub Actions (Fully Automated)
1. Follow `CREDENTIALS_SETUP.md` to configure GitHub Secrets
2. Push to main branch
3. GitHub Actions will automatically deploy!

#### Method 3: Manual
```bash
cd terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

cd ../ansible
ansible-playbook -i hosts.ini deploy.yml
```

### 📚 Documentation

- **`CREDENTIALS_SETUP.md`** - Step-by-step credential setup guide
- **`AWS_DEPLOYMENT_GUIDE.md`** - Comprehensive deployment guide
- **`terraform/`** - Terraform IaC files
- **`ansible/`** - Ansible playbooks

### 🌐 After Deployment

Your website will be live at: `http://<PUBLIC_IP>`

- Website files deployed to: `/var/www/portfolio`
- Web server: Nginx
- SSL/HTTPS: Can be added via AWS Certificate Manager

### 🧹 Cleanup

To destroy all AWS resources:
```bash
cd terraform
terraform destroy -var-file=terraform.tfvars
```

---

## 📂 Project Structure

```
Portfolio-html-css-js-bootstrap/
├── index.html                 # Main website
├── style.css                  # Main styles
├── css/
│   ├── color-*.css           # Color themes
│   └── style-switcher.css    # Theme switcher
├── js/
│   ├── script.js             # Main JS
│   └── style-switcher.js     # Theme JS
├── image/                    # Images
├── terraform/                # IaC for AWS
├── ansible/                  # Config management
├── .github/workflows/        # CI/CD pipelines
├── CREDENTIALS_SETUP.md      # Credentials guide
├── AWS_DEPLOYMENT_GUIDE.md   # Full deployment guide
└── deploy.sh                 # Quick deploy script
```

---

## 💰 AWS Cost Estimate

- **EC2 (t2.micro)**: $0/month (12 months free tier), then ~$9.50/month
- **Data Transfer**: $0/month (1GB free)
- **S3**: $0.50-2/month (5GB free tier)

**Total**: Free for 12 months, then ~$10-12/month

---

## 🔧 Technologies Used

- **Frontend**: HTML5, CSS3, JavaScript
- **Styling**: Bootstrap, Custom CSS
- **Icons**: Font Awesome
- **Infrastructure**: AWS (EC2, VPC, S3)
- **IaC**: Terraform
- **Config Mgmt**: Ansible
- **CI/CD**: GitHub Actions
- **Web Server**: Nginx

---

## 🔐 Security

- SSH key-based access to EC2
- Security groups with restricted ingress
- No hardcoded credentials
- GitHub Secrets for sensitive data
- Nginx security headers configured

For enhanced security, restrict SSH access to your IP in `terraform/main.tf`

---

## 🤝 Contributing

Feel free to fork and customize! Common modifications:
- Change colors in `css/color-*.css`
- Update content in `index.html`
- Add new sections to match your skills
- Deploy multiple versions using separate Terraform workspaces

---

## 📝 License

This project is open source and available under the MIT License.