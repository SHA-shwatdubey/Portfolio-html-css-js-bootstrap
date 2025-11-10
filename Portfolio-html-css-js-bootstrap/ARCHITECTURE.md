AWS PORTFOLIO DEPLOYMENT ARCHITECTURE
======================================

┌─────────────────────────────────────────────────────────────────┐
│                     YOUR LOCAL MACHINE                          │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │     Git      │  │  Terraform   │  │   Ansible    │         │
│  │              │  │              │  │              │         │
│  │ git push → main                                   │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ PUSH to GitHub
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      GITHUB REPOSITORY                          │
│                                                                 │
│  ├─ index.html                                                  │
│  ├─ css/                                                        │
│  ├─ js/                                                         │
│  ├─ terraform/ (IaC)                                           │
│  ├─ ansible/ (Config)                                          │
│  └─ .github/workflows/deploy.yml (CI/CD)                       │
│                                                                 │
│         ↓ (GitHub Actions Triggered)                           │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    GITHUB ACTIONS PIPELINE                      │
│                                                                 │
│  Step 1: Configure AWS Credentials                             │
│          ↓                                                      │
│  Step 2: Setup Terraform                                       │
│          ↓                                                      │
│  Step 3: Terraform Init → Plan → Apply                         │
│          ↓                                                      │
│  Step 4: Get EC2 Public IP                                     │
│          ↓                                                      │
│  Step 5: Wait for EC2 Ready                                    │
│          ↓                                                      │
│  Step 6: Setup Ansible & Run Playbook                          │
│          ↓                                                      │
│  Step 7: Verify Website & Report                               │
│                                                                 │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼ (Terraform Provisions)
┌─────────────────────────────────────────────────────────────────┐
│                      AWS ACCOUNT                                │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │            AWS VPC (Virtual Private Cloud)               │ │
│  │  10.0.0.0/16                                             │ │
│  │                                                           │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │        Public Subnet: 10.0.1.0/24                  │ │ │
│  │  │                                                     │ │ │
│  │  │  ┌──────────────────────────────────────────────┐  │ │ │
│  │  │  │      EC2 Instance (t2.micro)                │  │ │ │
│  │  │  │                                              │  │ │ │
│  │  │  │  ┌────────────────────────────────────────┐ │  │ │ │
│  │  │  │  │   Ubuntu 22.04 LTS                     │ │  │ │ │
│  │  │  │  │   - Nginx Web Server                   │ │  │ │ │
│  │  │  │  │   - Git (pulls your repo)              │ │  │ │ │
│  │  │  │  │   - /var/www/portfolio/                │ │  │ │ │
│  │  │  │  │     (your website files)                │ │  │ │ │
│  │  │  │  └────────────────────────────────────────┘ │  │ │ │
│  │  │  │                                              │  │ │ │
│  │  │  │  Private IP: 10.0.1.xx                       │  │ │ │
│  │  │  │  Elastic IP: 203.0.113.45 (Static)          │  │ │ │
│  │  │  └──────────────────────────────────────────────┘  │ │ │
│  │  │                                                     │ │ │
│  │  │  Security Group:                                    │ │ │
│  │  │  - Port 80 (HTTP) ← 0.0.0.0/0                      │ │ │
│  │  │  - Port 443 (HTTPS) ← 0.0.0.0/0                    │ │ │
│  │  │  - Port 22 (SSH) ← 0.0.0.0/0 (restrict to your IP)│ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │              ↑                        ↑                   │ │
│  │              └────────┬───────────────┘                   │ │
│  │                 Internet Gateway                         │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  S3 Bucket:                                                     │
│  portfolio-backup-<ACCOUNT_ID>  (for backups)                  │
│                                                                 │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼ (Configure via Ansible)
┌─────────────────────────────────────────────────────────────────┐
│              ANSIBLE CONFIGURATION MANAGEMENT                   │
│                                                                 │
│  1. Install Packages:                                           │
│     - Nginx                                                     │
│     - Git                                                       │
│                                                                 │
│  2. Clone Repository:                                           │
│     git clone https://github.com/USERNAME/repo.git             │
│     → /var/www/portfolio/                                       │
│                                                                 │
│  3. Configure Nginx:                                            │
│     - Copy nginx.conf.j2 template                              │
│     - Enable gzip compression                                  │
│     - Add security headers                                     │
│     - Cache static assets                                      │
│                                                                 │
│  4. Start Services:                                             │
│     - Start Nginx                                               │
│     - Enable auto-start on boot                                │
│                                                                 │
│  5. Health Check:                                               │
│     - Test HTTP response                                       │
│     - Verify website is running                                │
│                                                                 │
└────────────┬────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│                  🌍 LIVE WEBSITE 🌍                             │
│                                                                 │
│  Accessible at: http://203.0.113.45                            │
│  (Your Elastic IP)                                              │
│                                                                 │
│  User Browser                                                   │
│  ├─ GET / → index.html ✓                                        │
│  ├─ GET /css/style.css → cached (30 days) ✓                     │
│  ├─ GET /js/script.js → cached (30 days) ✓                      │
│  ├─ GET /image/xyz.jpg → cached (30 days) ✓                     │
│  └─ 404 errors handled gracefully ✓                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘


DEPLOYMENT FLOW DIAGRAM
========================

┌──────────────────────────────────────────────────────────────────┐
│ Developer Action: git push origin main                           │
└────────────────────┬─────────────────────────────────────────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │ GitHub Actions Start │
          └─────────┬────────────┘
                    │
          ┌─────────┴──────────┐
          │                    │
          ▼                    ▼
     ┌─────────┐          ┌──────────────┐
     │Terraform│          │ AWS Secrets  │
     │  Apply  │  Uses ←──┤  - Access Key│
     │         │          │  - Secret Key│
     └────┬────┘          └──────────────┘
          │
          │ Provisions
          │
          ▼
    ┌──────────────────┐
    │  AWS Resources   │
    ├──────────────────┤
    │ ✓ VPC            │
    │ ✓ EC2 Instance   │
    │ ✓ Security Group │
    │ ✓ Elastic IP     │
    │ ✓ S3 Bucket      │
    └────┬─────────────┘
         │
         ▼
    ┌──────────────┐
    │ EC2 Instance │
    │ Boots Up     │
    └────┬─────────┘
         │
         │ Waits for SSH
         │
         ▼
    ┌──────────────┐
    │   Ansible    │
    │   Playbook   │
    └────┬─────────┘
         │
         ├─→ Install Packages
         ├─→ Clone Repository
         ├─→ Configure Nginx
         ├─→ Enable Services
         └─→ Health Check
              │
              ▼
         ┌─────────────────┐
         │ ✓ LIVE WEBSITE! │
         └─────────────────┘


FUTURE ENHANCEMENTS
====================

You can extend this setup with:

1. SSL/TLS Certificate:
   - Use AWS Certificate Manager (free)
   - Enable HTTPS (port 443)
   - Auto-redirect HTTP to HTTPS

2. Custom Domain:
   - Register domain (Route 53 or external)
   - Point DNS to Elastic IP
   - Access at: https://yourdomain.com

3. CDN:
   - CloudFront distribution
   - Cache assets globally
   - Faster content delivery

4. Auto-Scaling:
   - Load Balancer
   - Multiple EC2 instances
   - Handle more traffic

5. Monitoring:
   - CloudWatch dashboards
   - Log aggregation
   - Email alerts

6. Database (if needed):
   - RDS (Managed database)
   - DynamoDB (NoSQL)
   - ElastiCache (Caching)

7. Backup Strategy:
   - S3 versioning
   - Automated snapshots
   - Disaster recovery


COST BREAKDOWN
==============

Free Tier (First 12 months):
┌─────────────────────┬───────┐
│ Service             │ Cost  │
├─────────────────────┼───────┤
│ EC2 t2.micro        │ FREE  │
│ (750 hours/month)   │       │
├─────────────────────┼───────┤
│ S3 Storage          │ FREE  │
│ (5GB)               │       │
├─────────────────────┼───────┤
│ Data Transfer Out   │ FREE  │
│ (1GB/month)         │       │
├─────────────────────┼───────┤
│ VPC, IGW, Subnets   │ FREE  │
├─────────────────────┼───────┤
│ TOTAL               │ $0    │
└─────────────────────┴───────┘

After Free Tier:
┌─────────────────────┬──────────┐
│ Service             │ Est Cost │
├─────────────────────┼──────────┤
│ EC2 t2.micro        │ $9.50    │
│ (744 hours/month)   │ /month   │
├─────────────────────┼──────────┤
│ S3 Storage          │ $0.50-2  │
│ (excess usage)      │ /month   │
├─────────────────────┼──────────┤
│ Data Transfer       │ Minimal  │
├─────────────────────┼──────────┤
│ TOTAL               │ ~$10-12  │
│                     │ /month   │
└─────────────────────┴──────────┘

Tip: Use `terraform destroy` to stop all charges!
