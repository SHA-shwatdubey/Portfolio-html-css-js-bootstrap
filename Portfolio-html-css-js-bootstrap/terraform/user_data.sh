#!/bin/bash
set -e

# Update system packages
apt-get update
apt-get upgrade -y

# Install Nginx
apt-get install -y nginx

# Install Git
apt-get install -y git

# Create web directory
mkdir -p /var/www/portfolio

# Clone repository
cd /var/www/portfolio
git clone ${repo_url} .

# Remove Nginx default config
rm -f /etc/nginx/sites-enabled/default

# Create Nginx config
cat > /etc/nginx/sites-available/portfolio << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    root /var/www/portfolio;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    error_page 404 /404.html;
}
EOF

# Enable Nginx config
ln -sf /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/

# Test Nginx config
nginx -t

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

echo "Deployment complete!"
