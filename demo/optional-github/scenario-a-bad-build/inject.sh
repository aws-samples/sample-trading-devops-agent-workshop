#!/bin/bash
# Lab 1: Inject Build Failure — Bad Docker base image
# Changes the market-data Dockerfile to use a non-existent image tag, so the
# CI/CD pipeline fails at the build step. Used by the FSI Autonomous Incident
# Response workshop (Module 1, Lab 1).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "Lab 1: Injecting Build Failure — Bad Docker Image"
echo "================================================="
echo
echo "Action: changing services/market-data/Dockerfile"
echo "  python:3.11-slim -> python:3.12-nonexistent"
echo

sed -i.bak 's/python:3.11-slim/python:3.12-nonexistent/' \
    "$REPO_ROOT/services/market-data/Dockerfile"
rm -f "$REPO_ROOT/services/market-data/Dockerfile.bak"

cd "$REPO_ROOT"
# Idempotent: only commit/push when the change actually modified something. A
# re-run (or a repo already on the broken image) leaves nothing staged, and
# `git commit` would otherwise fail under 'set -e'.
git add services/market-data/Dockerfile
if git diff --cached --quiet; then
    echo "Dockerfile already on the broken image tag — nothing to commit."
else
    git commit -m "feat: upgrade market-data base image to python:3.12-nonexistent

Upgrading base image for better performance."
    git push
fi

echo
echo "Injected. The pipeline will fail at the build-market-data job."
echo
echo "Expected behavior:"
echo "  1. Test stage passes"
echo "  2. build-market-data FAILS (manifest not found)"
echo "  3. Deploy and verify stages are skipped"
echo "  4. The notify-devops-agent job sends a webhook"
echo "  5. AWS DevOps Agent investigation starts"
echo
echo "Check the pipeline in your fork's Actions tab."
