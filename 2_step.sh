#!/bin/bash
PROJECT="dev-tools-369504"
VM_NAME="dev-vm-12h"

ZONE=$(gcloud compute instances list --project="$PROJECT" --filter="name=$VM_NAME" --format="value(zone)" 2>/dev/null | head -n 1)

if [ -z "$ZONE" ]; then
    echo "Error: Instance '$VM_NAME' not found in project '$PROJECT'." >&2
    echo "Run ./1_step.sh to create it." >&2
    exit 1
fi

if ! STATUS=$(gcloud compute instances describe "$VM_NAME" --project="$PROJECT" --zone="$ZONE" --format="value(status)"); then
    echo "Error: Failed to describe instance '$VM_NAME' in zone '$ZONE'." >&2
    exit 1
fi

if [ "$STATUS" = "TERMINATED" ]; then
    echo "Instance $VM_NAME is stopped in zone $ZONE. Starting..."
    if ! gcloud compute instances start "$VM_NAME" --project="$PROJECT" --zone="$ZONE"; then
        echo "Failed to start $VM_NAME in zone $ZONE." >&2
        echo "If the zone is out of resources, delete the VM with:" >&2
        echo "  gcloud compute instances delete $VM_NAME --project=$PROJECT --zone=$ZONE" >&2
        echo "and re-run ./1_step.sh to recreate it in an available zone." >&2
        exit 1
    fi
fi

gcloud compute ssh "$VM_NAME" --project="$PROJECT" --zone="$ZONE" -- -t "byobu"



