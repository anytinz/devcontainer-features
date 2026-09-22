#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)"
VENDOR_SCRIPT="${VENDOR_SCRIPT:-$ROOT/src/pnpm/vendor/install.sh}"

# The feature wrapper rewrites these assignments and this download base.
grep -q '^NPM_REGISTRY=' "$VENDOR_SCRIPT"
grep -q '^NPM_SIGNING_KEY_ID=' "$VENDOR_SCRIPT"
grep -q '^NPM_SIGNING_KEY=' "$VENDOR_SCRIPT"
grep -qF 'https://github.com/pnpm/pnpm/releases/download' "$VENDOR_SCRIPT"
