#!/usr/bin/env bash
set -euo pipefail
cat > config.py <<'PY'
API_SECRET = "sk-live-123"  # hard-coded secret
PY
