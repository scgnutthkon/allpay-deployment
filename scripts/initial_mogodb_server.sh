#!/bin/bash

# Fetch and install MongoDB GPG key
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
    sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
    --dearmor --yes

# Add MongoDB repository
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

# Update package list
sudo apt-get update

# Install MongoDB
sudo apt-get install -y mongodb-org

# Enable MongoDB service
sudo systemctl enable mongod

# Get the server's IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

# Update MongoDB configuration to allow connections from the server's IP address and localhost
sudo sed -i "s/bindIp: 127.0.0.1/bindIp: 127.0.0.1,$SERVER_IP/" /etc/mongod.conf

# Restart MongoDB service to apply changes
sudo systemctl restart mongod