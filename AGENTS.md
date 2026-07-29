# AGENTS.md

## Project
Provisioning and SSH helper scripts for setting up an auto-expiring GCP Compute Engine Debian dev VM preconfigured with Go, gcloud, and Antigravity.

## Commands
- Install/Provision: `./1_step.sh`
- SSH/Connect: `./2_step.sh`
- Syntax check: `bash -n *.sh`
- Lint: `shellcheck *.sh`

## Conventions
- Language: Bash (`#!/bin/bash`). Match existing style.
- Standard POSIX / Bash shell tools and Google Cloud SDK (`gcloud`).
- Guard operations with sentinel/existence checks and use strict exit handling where appropriate.
- Quote shell variables and parameters properly.

## Working rules
- Read a file fully before editing it.
- Allow read-only commands (e.g., `git status`, `git diff`, `git log`, `ls`, `cat`, `grep`, `bash -n`, `shellcheck`, `gcloud info`, etc.) in the current project without asking for state-modifying confirmation.
- Smallest change that solves the stated problem. No drive-by refactors, renames, or reformatting.
- If the task is ambiguous or needs a design decision, stop and ask instead of guessing.
- Found an unrelated bug? Report it, do not fix it in the same change.
- Follow existing patterns even if you would write it differently.

## Before finishing
- Run syntax check (`bash -n *.sh`) and lint (`shellcheck *.sh` if installed). Report failures you did not cause.
- Summarize: what changed, why, and what you deliberately left alone.

## Do not
- Commit, push, or open a PR unless asked.
- Touch lockfiles, generated code, or CI config silently.
- Add comments that restate the code.
