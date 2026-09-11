#!/bin/bash
PROJECT="dev-tools-369504"
VM_NAME="dev-vm-12h"

ACCOUNT_ARGS=()
if [ -n "$ACCOUNT" ]; then
    ACCOUNT_ARGS=(--account="$ACCOUNT")
fi

if [ -z "$ZONE" ]; then
    ZONE=$(gcloud compute instances list "${ACCOUNT_ARGS[@]}" --project="$PROJECT" --filter="name=$VM_NAME" --format="value(zone)" 2>/dev/null | head -n 1)
fi

if [ -z "$ZONE" ]; then
    echo "Error: Instance '$VM_NAME' not found in project '$PROJECT'." >&2
    echo "Run ./1_step.sh to create it." >&2
    exit 1
fi

if ! STATUS=$(gcloud compute instances describe "$VM_NAME" "${ACCOUNT_ARGS[@]}" --project="$PROJECT" --zone="$ZONE" --format="value(status)"); then
    echo "Error: Failed to describe instance '$VM_NAME' in zone '$ZONE'." >&2
    exit 1
fi

if [ "$STATUS" = "TERMINATED" ]; then
    echo "Instance $VM_NAME is stopped in zone $ZONE. Starting..."
    if ! gcloud compute instances start "$VM_NAME" "${ACCOUNT_ARGS[@]}" --project="$PROJECT" --zone="$ZONE"; then
        echo "Failed to start $VM_NAME in zone $ZONE." >&2
        echo "If the zone is out of resources, delete the VM with:" >&2
        echo "  gcloud compute instances delete $VM_NAME --project=$PROJECT --zone=$ZONE" >&2
        echo "and re-run ./1_step.sh to recreate it in an available zone." >&2
        exit 1
    fi
fi

ERR_OUTPUT=$(gcloud compute ssh "$VM_NAME" "${ACCOUNT_ARGS[@]}" --project="$PROJECT" --zone="$ZONE" --command="test -f /var/log/startup_script_done" 2>&1)
STATUS_CODE=$?

if [ "$STATUS_CODE" -eq 1 ] && [ -z "$ERR_OUTPUT" ]; then
    echo "Error: VM startup script is still running (installing byobu, Go, and dev tools)." >&2
    echo "Please wait a moment for setup to finish and try again." >&2
    exit 1
elif [ "$STATUS_CODE" -ne 0 ]; then
    echo "Error: Failed to connect to $VM_NAME via SSH (exit code $STATUS_CODE)." >&2
    if [ -n "$ERR_OUTPUT" ]; then
        printf '%s\n' "$ERR_OUTPUT" >&2
    fi
    exit "$STATUS_CODE"
fi

gcloud compute ssh "$VM_NAME" "${ACCOUNT_ARGS[@]}" --project="$PROJECT" --zone="$ZONE" -- -t "byobu || tmux || bash"



