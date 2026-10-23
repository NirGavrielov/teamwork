#!/usr/bin/env bash
# An auth change: should be tiered High.
set -euo pipefail
cat > auth.py <<'PY'
USERS = {"ada": "hash-of-secret"}

def login(user, password_hash):
    return USERS.get(user) == password_hash
PY
