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

for z in "${ZONES[@]}"; do
    echo "Attempting to create $VM_NAME in zone $z..."
    if OUTPUT=$(gcloud compute instances create "$VM_NAME" \
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
        --metadata-from-file=startup-script=startup.sh 2>&1); then
        [ -n "$OUTPUT" ] && printf '%s\n' "$OUTPUT"
        echo "Successfully created $VM_NAME in zone $z."
        exit 0
    fi

    [ -n "$OUTPUT" ] && printf '%s\n' "$OUTPUT" >&2

    if printf '%s\n' "$OUTPUT" | grep -qiE "permission|not have permission|PERMISSION_DENIED|403"; then
        echo "Error: Permission denied for project '$PROJECT'." >&2
        echo "Active account: $(gcloud config get-value account 2>/dev/null)" >&2
        echo "Switch accounts with 'gcloud config set account <account>' or pass ACCOUNT=<account>." >&2
        exit 1
    fi

    if printf '%s\n' "$OUTPUT" | grep -qi "already exists"; then
        echo "Error: Instance '$VM_NAME' already exists in zone $z." >&2
        exit 1
    fi

    echo "Creation failed in zone $z. Trying next zone..."
done

echo "Error: Could not create $VM_NAME in any attempted zone." >&2
exit 1

