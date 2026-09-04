#!/bin/bash
# Lab 1: Fix Build Failure — Restore valid Docker base image
# Reverts the market-data Dockerfile back to python:3.11-slim, commits, and
# pushes. Used by the FSI Autonomous Incident Response workshop (Module 1, Lab 1).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "Lab 1: Fixing Build Failure — Restoring Valid Image"
echo "==================================================="
echo
echo "Action: reverting services/market-data/Dockerfile"
echo "  FROM python:3.12-nonexistent -> python:3.11-slim"
echo

sed -i.bak 's/FROM python:3.12-nonexistent/FROM python:3.11-slim/' \
    "$REPO_ROOT/services/market-data/Dockerfile"
rm -f "$REPO_ROOT/services/market-data/Dockerfile.bak"

cd "$REPO_ROOT"
# Idempotent: only commit/push when the revert actually changed something. A
# re-run (or a repo already on the good image) leaves nothing staged, and
# `git commit` would otherwise fail under 'set -e'.
git add services/market-data/Dockerfile
if git diff --cached --quiet; then
    echo "Dockerfile already on the valid base image — nothing to commit."
else
    git commit -m "fix: restore valid Docker base image python:3.11-slim

Reverts invalid image tag 'python:3.12-nonexistent' back to
'python:3.11-slim' per AWS DevOps Agent mitigation spec.

Resolves: build-market-data job failure (manifest not found)"
    git push
fi

echo
echo "Fixed. The pipeline should go green now."
echo
echo "Check the pipeline in your fork's Actions tab."
