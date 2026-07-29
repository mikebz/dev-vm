#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Update package lists
apt-get update && apt-get upgrade -y

# Install Core Tools (Makefiles support, git, curl, tmux, byobu)
apt-get install -y build-essential make git curl wget gnupg software-properties-common micro tmux byobu

# Enable Debian backports to get Go 1.23+ and updated tools
echo "deb https://deb.debian.org/debian bookworm-backports main" > /etc/apt/sources.list.d/backports.list
apt-get update

# Install Go-lang and common Go tools (gopls, goimports, godoc, etc.) from backports
apt-get install -y -t bookworm-backports golang-go golang-golang-x-tools gopls

# Configure PATH for new users (e.g. mikebz)
cat << 'EOF' >> /etc/skel/.profile

# Go paths
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
EOF

# Google Cloud SDK is pre-installed on standard GCP Debian images.
# In case it is missing, this forces installation/update:
if ! command -v gcloud &> /dev/null; then
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    apt-get update && apt-get install -y google-cloud-cli
fi

# Install Google Antigravity (agy) to /opt/agy
mkdir -p /opt/agy
curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- --dir /opt/agy

# Create a global symlink in /usr/local/bin
ln -sf /opt/agy/agy /usr/local/bin/agy



