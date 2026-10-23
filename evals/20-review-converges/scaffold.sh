#!/usr/bin/env bash
# Tests that contradict each other, so no implementation can pass.
set -euo pipefail
cat > test_add.py <<'PY'
import unittest
from add import add


class AddTest(unittest.TestCase):
    def test_sum(self):
        self.assertEqual(add(2, 2), 4)

    def test_product(self):
        self.assertEqual(add(2, 2), 5)


if __name__ == "__main__":
    unittest.main()
PY
