# 🚀 GitHub Actions Setup Guide - Automatic Deployment

## Your Setup Details

```
GitHub Repository: https://github.com/SHA-shwatdubey/Portfolio-html-css-js-bootstrap.git
AWS Region: ap-southeast-1 (Singapore)
Deploy Method: GitHub Actions (Automatic on every push)
```

---

## ✅ STEP 1: Add GitHub Secrets (5 Required)

Go to: **GitHub → Your Repository → Settings → Secrets and variables → Actions**

### Click "New repository secret" and add these 5 secrets:

#### Secret #1: AWS_ACCESS_KEY_ID
- Name: `AWS_ACCESS_KEY_ID`
- Value: `AKIA...` (from your AWS IAM user)

#### Secret #2: AWS_SECRET_ACCESS_KEY
- Name: `AWS_SECRET_ACCESS_KEY`
- Value: Your AWS secret access key (⚠️ never share this!)

#### Secret #3: AWS_REGION
- Name: `AWS_REGION`
- Value: `ap-southeast-1`

#### Secret #4: SSH_PRIVATE_KEY
- Name: `SSH_PRIVATE_KEY`
- Value: **PASTE YOUR ENTIRE PRIVATE KEY** (see below)

To get your SSH private key, run:
```bash
cat ~/.ssh/id_rsa
```

Copy the ENTIRE output including:
```
-----BEGIN OPENSSH PRIVATE KEY-----
[entire key content]
-----END OPENSSH PRIVATE KEY-----
```

#### Secret #5: GITHUB_REPO_URL
- Name: `GITHUB_REPO_URL`
- Value: `https://github.com/SHA-shwatdubey/Portfolio-html-css-js-bootstrap.git`

---

## ✅ STEP 2: Verify GitHub Secrets Are Added

Your 5 secrets should look like:
```
✅ AWS_ACCESS_KEY_ID        = AKIA...
✅ AWS_SECRET_ACCESS_KEY    = [hidden]
✅ AWS_REGION               = ap-southeast-1
✅ SSH_PRIVATE_KEY          = [hidden]
✅ GITHUB_REPO_URL          = https://github.com/SHA-shwatdubey/...
```

---

## ✅ STEP 3: Enable GitHub Actions

1. Go to **Actions** tab in your repository
2. If prompted, click "I understand my workflows, go ahead and enable them"
3. Done! ✅

---

## ✅ STEP 4: Trigger First Deployment

### Option A: Via Git Push (Recommended)
```bash
git add .
git commit -m "Setup AWS deployment with Terraform and Ansible"
git push origin main
```

### Option B: Manual Trigger (via GitHub UI)
1. Go to **Actions** tab
2. Select **"Deploy Portfolio to AWS (Singapore)"** workflow
3. Click **"Run workflow"**
4. Click green **"Run workflow"** button

---

## 📊 What Happens During Deployment

When you push to main, GitHub Actions will:

1. **Configure AWS** using your secrets
2. **Setup Terraform** in the workflow
3. **Initialize Terraform**
4. **Plan infrastructure** (preview changes)
5. **Apply Terraform** (create AWS resources):
   - VPC in Singapore region
   - EC2 instance (t2.micro)
   - Security groups
   - Elastic IP
   - S3 bucket
6. **Get Public IP** from Terraform
7. **Setup SSH** for server connection
8. **Wait for EC2** to be ready (up to 180 seconds)
9. **Setup Ansible** in the workflow
10. **Create Ansible inventory** with public IP
11. **Run Ansible playbook** to:
    - Install Nginx
    - Clone your GitHub repository
    - Configure web server
    - Start services
12. **Verify deployment** (curl check)
13. **Create summary** with website URL

---

## 🔍 Monitor Deployment

### Watch the Deployment Live:

1. Go to **Actions** tab in GitHub
2. Click on the running workflow
3. See real-time logs
4. Check for any errors

### Deployment Status:
- 🟡 Yellow dot = Running
- 🟢 Green checkmark = Success
- 🔴 Red X = Failed

---

## 🌍 After Successful Deployment

You'll see a summary with:
```
✅ Deployment Complete!

Website URL: http://203.0.113.45
Instance ID: i-0123456789abcdef
Region: ap-southeast-1 (Singapore)
```

Your website will be live at that IP! 🎉

---

## 🚨 Troubleshooting

### If Deployment Fails:

**Check the logs:**
1. Go to **Actions** tab
2. Click on the failed workflow
3. Click on the failed job
4. Check error messages

**Common Issues:**

1. **"Invalid credentials"**
   - Check AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in Secrets
   - Re-run deployment

2. **"SSH key invalid"**
   - Check SSH_PRIVATE_KEY includes -----BEGIN----- and -----END-----
   - No extra spaces or line breaks

3. **"Terraform apply failed"**
   - Check AWS_REGION is set to `ap-southeast-1`
   - Check AWS account has enough quota

4. **"EC2 instance not ready"**
   - Wait longer (EC2 can take 2-3 minutes)
   - Re-run workflow

5. **"Ansible playbook failed"**
   - Check SSH connectivity
   - Check repository URL is correct

---

## 🔄 Automatic Deployments After First Success

Once set up, every time you:
```bash
git push origin main
```

Your website will automatically:
1. ✅ Update infrastructure if needed
2. ✅ Pull latest code from GitHub
3. ✅ Redeploy website
4. ✅ Restart services

**No manual work needed!** 🚀

---

## 📋 Full Workflow Commands (For Reference)

The GitHub Actions workflow does these behind the scenes:

```bash
# 1. AWS Configuration
export AWS_ACCESS_KEY_ID = [your secret]
export AWS_SECRET_ACCESS_KEY = [your secret]

# 2. Terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -auto-approve tfplan

# 3. Get IP
terraform output instance_public_ip

# 4. SSH Setup
mkdir -p ~/.ssh
echo [SSH_PRIVATE_KEY] > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# 5. Ansible
ansible-playbook -i hosts.ini deploy.yml

# 6. Verify
curl http://[PUBLIC_IP]/
```

---

## 💡 Next Steps

1. ✅ Add 5 GitHub Secrets (as detailed above)
2. ✅ Push to main branch (or manually trigger)
3. ✅ Watch Actions tab for deployment
4. ✅ Wait for completion (~15 minutes)
5. ✅ Access website at provided IP
6. ✅ Celebrate! 🎉

---

## 🎯 Quick Reference

| Item | Value |
|------|-------|
| GitHub Repo | https://github.com/SHA-shwatdubey/Portfolio-html-css-js-bootstrap.git |
| AWS Region | ap-southeast-1 (Singapore) |
| Deployment Method | GitHub Actions (automatic) |
| Trigger | Push to main branch |
| Deploy Time | ~15 minutes |
| Cost | Free tier ($0 for 12 months) |

---

## ✨ You're All Set!

Everything is configured for automatic deployment:

✅ AWS configured (region: Singapore)
✅ SSH keys generated
✅ Terraform ready
✅ Ansible ready
✅ GitHub Actions workflow ready

### Now Just:
1. Add 5 GitHub Secrets
2. Push to main
3. Watch it deploy! 🚀

---

**Questions?** Check the logs in GitHub Actions tab!
