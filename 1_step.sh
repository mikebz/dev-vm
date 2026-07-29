#!/bin/bash
gcloud compute instances create dev-vm-12h \
    --project=dev-tools-369504 \
    --zone=us-west1-a \
    --machine-type=e2-standard-2 \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --max-run-duration=12h \
    --instance-termination-action=stop \
    --metadata-from-file=startup-script=startup.sh
