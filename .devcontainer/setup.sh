#!/bin/bash

set -eo pipefail

# install terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# install azure cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# install checkov
pip install checkov --no-cache-dir

# install tflint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

#install pre-commit
pip install pre-commit --no-cache-dir
