#!/bin/bash
STATUS=$(gcloud compute instances describe dev-vm-12h --project=dev-tools-369504 --zone=us-west1-a --format="value(status)" 2>/dev/null)

if [ "$STATUS" = "TERMINATED" ] || [ "$STATUS" = "STOPPED" ]; then
    echo "Instance dev-vm-12h is stopped. Starting..."
    gcloud compute instances start dev-vm-12h --project=dev-tools-369504 --zone=us-west1-a
fi

gcloud compute ssh dev-vm-12h --project=dev-tools-369504 --zone=us-west1-a -- -t "byobu"

