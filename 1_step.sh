#!/bin/bash
PROJECT="dev-tools-369504"
VM_NAME="dev-vm-12h"
ZONES=("us-west1-a" "us-west1-b" "us-west1-c" "us-central1-a" "us-central1-b" "us-central1-f" "us-east1-b" "us-east1-c")

if [ -n "$ZONE" ]; then
    ZONES=("$ZONE")
fi

ACCOUNT_ARGS=()
if [ -n "$ACCOUNT" ]; then
    ACCOUNT_ARGS=(--account="$ACCOUNT")
fi

EXISTING_ZONE=$(gcloud compute instances list "${ACCOUNT_ARGS[@]}" --project="$PROJECT" --filter="name=$VM_NAME" --format="value(zone)" 2>/dev/null | head -n 1)

if [ -n "$EXISTING_ZONE" ]; then
    echo "Error: Instance '$VM_NAME' already exists in zone '$EXISTING_ZONE'." >&2
    echo "Run ./2_step.sh to connect to it." >&2
    exit 1
fi

for z in "${ZONES[@]}"; do
    echo "Attempting to create $VM_NAME in zone $z..."
    if gcloud compute instances create "$VM_NAME" \
        "${ACCOUNT_ARGS[@]}" \
        --project="$PROJECT" \
        --zone="$z" \
        --machine-type=e2-standard-2 \
        --boot-disk-size=30GB \
        --boot-disk-type=pd-balanced \
        --image-family=debian-12 \
        --image-project=debian-cloud \
        --max-run-duration=12h \
        --instance-termination-action=stop \
        --metadata-from-file=startup-script=startup.sh; then
        echo "Successfully created $VM_NAME in zone $z."
        exit 0
    fi
    echo "Creation failed in zone $z. Trying next zone..."
done

echo "Error: Could not create $VM_NAME in any attempted zone." >&2
exit 1

