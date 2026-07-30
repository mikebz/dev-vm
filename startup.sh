#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
# GCP metadata script runner executes as root on boot, but HOME may be unbound.
# Fallback to /root for root system setup tasks (normal user sessions use /home/<user>).
export HOME="${HOME:-/root}"

# Check if startup script has already executed on a previous boot
SENTINEL="/var/log/startup_script_done"
if [ -f "$SENTINEL" ]; then
    echo "Startup script has already executed on first boot. Skipping."
    exit 0
fi

# Update package lists
apt-get update && apt-get upgrade -y

# Install Core Tools (Makefiles support, git, curl, tmux, byobu)
apt-get install -y build-essential make git curl wget gnupg software-properties-common micro tmux byobu

# Enable Debian backports to get Go 1.23+ and updated tools
echo "deb https://deb.debian.org/debian bookworm-backports main" > /etc/apt/sources.list.d/backports.list
apt-get update

# Install Go-lang and common Go tools (gopls, goimports, godoc, etc.) from backports
apt-get install -y -t bookworm-backports golang-go golang-golang-x-tools gopls

# Install golangci-lint CLI (pinned)
GOLANGCI_LINT_VERSION="v1.61.0"
if ! command -v golangci-lint &> /dev/null; then
    tmp="$(mktemp)"
    curl -sSfL "https://raw.githubusercontent.com/golangci/golangci-lint/${GOLANGCI_LINT_VERSION}/install.sh" -o "$tmp"
    sh "$tmp" -b /usr/local/bin "${GOLANGCI_LINT_VERSION}"
    rm -f "$tmp"
fi


# Configure PATH system-wide and for user profiles
cat << 'EOF' > /etc/profile.d/go.sh
# Go paths
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
EOF

if [ ! -f /etc/skel/.profile ] || ! grep -q "GOPATH" /etc/skel/.profile; then
cat << 'EOF' >> /etc/skel/.profile

# Go paths
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
EOF
fi

for profile in /home/*/.profile; do
    if [ -f "$profile" ] && ! grep -q "GOPATH" "$profile"; then
cat << 'EOF' >> "$profile"

# Go paths
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
EOF
    fi
done


# Google Cloud SDK is pre-installed on standard GCP Debian images.
# In case it is missing, this forces installation/update:
if ! command -v gcloud &> /dev/null; then
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    apt-get update && apt-get install -y google-cloud-cli
fi

# Install Google Antigravity (agy) to /opt/agy
if [ ! -f /opt/agy/agy ]; then
    mkdir -p /opt/agy
    curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- --dir /opt/agy
    if [ -f /opt/agy/agy ]; then
        ln -sf /opt/agy/agy /usr/local/bin/agy
    fi
fi

# Mark startup script as completed
touch "$SENTINEL"
