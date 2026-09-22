#!/bin/sh
set -eu

TEST_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
ROOT="$(CDPATH= cd -- "$TEST_DIR/../.." && pwd)"
VENDOR_SCRIPT="$ROOT/src/pnpm/vendor/install.sh"
CANDIDATE="$(mktemp)"
trap 'rm -f "$CANDIDATE"' EXIT HUP INT TERM

# Establish that the real vendor script passes before checking a mutated copy.
sh "$TEST_DIR/vendor_rewrite_points.sh"
sed "$1" "$VENDOR_SCRIPT" > "$CANDIDATE"
if cmp -s "$VENDOR_SCRIPT" "$CANDIDATE"; then
    printf 'Could not remove %s from the vendor fixture\n' "$2" >&2
    exit 1
fi
if VENDOR_SCRIPT="$CANDIDATE" sh "$TEST_DIR/vendor_rewrite_points.sh"; then
    printf 'Accepted vendor script without %s\n' "$2" >&2
    exit 1
fi
