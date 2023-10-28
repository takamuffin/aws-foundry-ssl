#!/bin/bash

# These files are created in the CloudFormation script
source /foundryssl/variables.sh
source /foundryssl/variables_tmp.sh

# Set up logging to the logfile
exec >> /tmp/foundry-setup.log 2>&1
set -x

# Install foundry
echo "===== 1. INSTALLING DEPENDENCIES ====="
sudo dnf install https://rpm.nodesource.com/pub_20.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y
sudo dnf install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1
sudo dnf install -y openssl-devel
sudo dnf install -y amazon-cloudwatch-agent

# Install foundry
echo "===== 2. INSTALLING FOUNDRY ====="
source /aws-foundry-ssl/setup/foundry.sh

# Install nginx
echo "===== 3. INSTALLING NGINX ====="
source /aws-foundry-ssl/setup/nginx.sh

# Amazon Cloudwatch logs, zone updates and kernel patching
echo "===== 4. INSTALLING AWS SERVICES AND LINUX KERNEL PATCHING ====="
source /aws-foundry-ssl/setup/aws_cloudwatch_config.sh
source /aws-foundry-ssl/setup/aws_hosted_zone_id.sh
source /aws-foundry-ssl/setup/aws_linux_updates.sh

# Set up SSL certificates with LetsEncrypt
echo "===== 5. INSTALLING LETSENCRYPT CERTBOT ====="
source /aws-foundry-ssl/setup/certbot.sh

# Restart Foundry so aws-s3.json is fully loaded
echo "===== 6. RESTARTING FOUNDRY ====="
sudo systemctl restart foundry

# Clean up install files (Comment out during testing)
echo "===== 7. CLEANUP AND USER PERMISSIONS ====="
sudo usermod -a -G foundry ec2-user
sudo chown ec2-user -R /aws-foundry-ssl

sudo chmod 744 /aws-foundry-ssl/utils/*.sh
sudo chmod 700 /tmp/foundry-setup.log
sudo rm /foundryssl/variables_tmp.sh

# Uncomment only if you really care to:
# sudo rm -r /aws-foundry-ssl

echo "===== 8. DONE ====="
echo "Finished setting up Foundry!"
