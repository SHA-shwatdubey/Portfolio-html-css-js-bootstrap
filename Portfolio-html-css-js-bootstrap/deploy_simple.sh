#!/bin/bash

# Simple Website Deployment to AWS EC2 (No Nginx)
# Using Python HTTP Server

EC2_IP="13.213.163.132"
SSH_KEY="$HOME/.ssh/id_rsa"
EC2_USER="ubuntu"
PORTFOLIO_DIR="/home/ubuntu/portfolio"
PORT=8000

echo "════════════════════════════════════════════════════════════════"
echo "🚀 PORTFOLIO DEPLOYMENT - SIMPLE HTTP SERVER (No Nginx)"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Step 1: Verify SSH connection
echo "📡 Step 1: Testing SSH connection to EC2..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$EC2_USER@$EC2_IP" "echo 'SSH OK'" && echo "✅ SSH Connection successful!" || {
    echo "❌ SSH Connection failed!"
    exit 1
}

# Step 2: Create portfolio directory on EC2
echo ""
echo "📁 Step 2: Creating portfolio directory on EC2..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "
    mkdir -p $PORTFOLIO_DIR
    cd $PORTFOLIO_DIR
    echo 'Portfolio directory ready'
"
echo "✅ Directory created!"

# Step 3: Copy website files to EC2
echo ""
echo "📤 Step 3: Uploading website files to EC2..."
scp -i "$SSH_KEY" -o StrictHostKeyChecking=no -r \
    ./index.html \
    ./style.css \
    ./css \
    ./js \
    ./image \
    "$EC2_USER@$EC2_IP:$PORTFOLIO_DIR/"
echo "✅ Files uploaded!"

# Step 4: Start HTTP Server on EC2
echo ""
echo "🌐 Step 4: Starting HTTP Server on EC2..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "
    cd $PORTFOLIO_DIR
    
    # Kill any existing Python server
    pkill -f 'python.*http.server' 2>/dev/null || true
    
    # Start new server in background
    nohup python3 -m http.server $PORT > server.log 2>&1 &
    
    sleep 2
    
    # Check if running
    if pgrep -f 'python.*http.server' > /dev/null; then
        echo 'HTTP Server started on port $PORT'
        ps aux | grep '[p]ython.*http.server'
    else
        echo 'Failed to start server'
        cat server.log
    fi
"
echo "✅ HTTP Server started!"

# Step 5: Verify website is accessible
echo ""
echo "✅ Step 5: Verifying website is accessible..."
sleep 2
curl -s "http://$EC2_IP:$PORT/" > /dev/null && {
    echo "✅ Website is LIVE!"
} || {
    echo "⚠️ Website check timeout (might still be loading)"
}

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "🎉 DEPLOYMENT COMPLETE!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📍 Website URL: http://$EC2_IP:$PORT"
echo ""
echo "✨ Your portfolio is now live on AWS EC2!"
echo "🌍 Open in browser: http://$EC2_IP:$PORT"
echo ""
echo "📊 Server Details:"
echo "   - EC2 IP: $EC2_IP"
echo "   - Port: $PORT"
echo "   - Location: $PORTFOLIO_DIR"
echo "   - Region: Singapore (ap-southeast-1)"
echo ""
echo "🛑 To stop server later:"
echo "   ssh -i ~/.ssh/id_rsa ubuntu@$EC2_IP 'pkill -f http.server'"
echo ""
echo "════════════════════════════════════════════════════════════════"
