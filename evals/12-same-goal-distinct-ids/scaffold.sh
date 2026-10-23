#!/usr/bin/env bash
# An earlier job today with the same goal, under every slug the lead is likely
# to pick, so the new job must get a -2 suffix instead of reusing a directory.
set -euo pipefail
d=$(date +%F)
for slug in hello-cli add-hello-cli add-a-hello-cli hello-world-cli hello-cli-tool python-hello-cli hello-world-python-cli; do
  mkdir -p ".teamwork/jobs/$d-$slug/logs"
  printf '# Plan: add a hello CLI\n\nStatus: done (earlier job, fixture).\n' > ".teamwork/jobs/$d-$slug/plan.md"
  printf 'fixture log\n' > ".teamwork/jobs/$d-$slug/logs/team-lead.md"
done
