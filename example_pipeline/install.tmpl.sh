#! /bin/bash

set -e
set -x

sudo apt-get update
sudo apt-get install -y curl ca-certificates gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
curl -sSL https://get.buddy.works | sudo sh
sudo buddy --yes install-worker --token="STANDALONE_TOKEN" --standalone-host="https://STANDALONE_HOST" --tag="RUNNER_TAG" --concurrent="RUNNER_SLOTS"
