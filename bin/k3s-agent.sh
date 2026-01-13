#!/bin/bash
# Get the server node's IP from the arguments
SERVER_IP=$1

# Get the token from the shared folder
TOKEN=$(cat /vagrant/token)

# Install K3s agent and join the server node
curl -sfL https://get.k3s.io | K3S_URL=https://$SERVER_IP:6443 K3S_TOKEN=$TOKEN sh -
