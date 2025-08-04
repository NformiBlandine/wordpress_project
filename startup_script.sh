#!/bin/bash

set -e




echo -e "Checking for Docker installation..."

if ! command -v docker &> /dev/null
then
    echo -e "Docker is not installed. Installing Docker..."

    # Remove old versions
    sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

    # Update package list
    sudo apt-get update

    # Install required packages
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Add Docker’s official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Set up the repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update package index and install Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Enable and start Docker
    sudo systemctl enable docker
    sudo systemctl start docker

    echo -e "Docker installed successfully!"
else
    echo -e "Docker is already installed."
fi

echo -e "Checking for Docker Compose plugin..."

if ! docker compose version &> /dev/null
then
    echo -e "Docker Compose plugin not found. Installing it..."
    sudo apt-get install -y docker-compose-plugin
    echo -e "Docker Compose plugin installed successfully!"
else
    echo -e "Docker Compose is already installed."
fi

# Optional: Add user to docker group
if ! groups $USER | grep -q "\bdocker\b"; then
    echo -e "Adding user to docker group..."
    sudo usermod -aG docker $USER
    echo -e "You may need to log out and back in for group changes to take effect."
fi

echo -e "✅ All done!"
