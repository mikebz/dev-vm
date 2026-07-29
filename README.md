# Setup Guide: Auto-Expiring GCP Dev Environment

This repository contains helper scripts to provision a Debian-based Google Cloud Compute Engine instance that automatically shuts down after **12 hours** and comes pre-configured with Go, gcloud SDK, `make`, and other core tools.

## Repository Contents

* `1_step.sh`: Command to create the VM instance.
* `startup.sh`: Startup script installed on boot to configure the VM's tools.
* `2_step.sh`: Command to connect to the VM via SSH.

---

## Step 1: Create the Instance

Run the script to provision the VM:
```bash
./1_step.sh
```

This runs the following `gcloud` command:
```bash
gcloud compute instances create dev-vm-12h \
    --project=dev-tools-369504 \
    --zone=us-west1-a \
    --machine-type=e2-standard-2 \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --max-run-duration=12h \
    --instance-termination-action=stop \
    --metadata-from-file=startup-script=startup.sh
```

The VM's startup script (`startup.sh`) automatically runs on the first boot to install core dependencies (Git, Make, Go, Google Cloud CLI):
```bash
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Update package lists
apt-get update && apt-get upgrade -y

# Install Core Tools (Makefiles support, git, curl)
apt-get install -y build-essential make git curl wget gnupg software-properties-common micro

# Install Go-lang and common Go tools (gopls, goimports, godoc, gorename, etc.)
apt-get install -y golang-go golang-golang-x-tools gopls

# Configure PATH for new users (e.g. mikebz)
cat << 'EOF' >> /etc/skel/.profile

# Go paths
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
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
```

---

## Step 2: Establish Local SSH Connection

Once the VM creation finishes, run the script to connect to the VM over SSH:
```bash
./2_step.sh
```

This runs the native `gcloud` SSH wrapper:
```bash
gcloud compute ssh dev-vm-12h --project=dev-tools-369504 --zone=us-west1-a
```
