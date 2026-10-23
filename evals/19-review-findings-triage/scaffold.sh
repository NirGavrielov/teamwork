#!/usr/bin/env bash
# Code with one real bug plus review findings of mixed quality.
set -euo pipefail
cat > calc.py <<'PY'
def average(xs):
    return sum(xs) / len(xs) + 1   # off by one


def ratio(a, b):
    return a / b                   # divides by zero when b == 0 (existed before this change)
PY
cat > FINDINGS.md <<'MD'
# Automated reviewer findings on the latest change to calc.py (unverified)

1. average() adds 1 to the result, so every average is wrong.
2. parse_input() does not strip whitespace before converting to float.
3. Variable names xs, a and b are too short; rename them.
4. ratio() raises ZeroDivisionError when b is 0. This code is unchanged by the latest change.
MD
