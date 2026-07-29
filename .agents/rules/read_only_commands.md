# Read-Only Commands Rule

Allow read-only commands in the current project without prompt or confirmation.

## Allowed Read-Only Commands
- `git status`, `git diff`, `git log`, `git show`, `git branch`, `git remote`, `git fetch`
- `ls`, `dir`, `cat`, `grep`, `find`, `head`, `tail`, `wc`
- `bash -n <file>`, `sh -n <file>`, `shellcheck <file>`
- `gcloud info`, `gcloud components list`, `gcloud compute instances list`
- `env`, `which`, `ps`

## Constraints
- Commands that modify repository state, VM resources, or system state (e.g. `git commit`, `git push`, `gcloud compute instances create`, `gcloud compute instances delete`, `rm`, `chmod`) require user confirmation.
