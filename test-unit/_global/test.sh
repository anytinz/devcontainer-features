#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
    printf 'Usage: sh %s <feature>\n' "$0" >&2
    exit 2
fi

case "$1" in
    ''|_global|*[!a-zA-Z0-9_-]*)
        printf 'Invalid feature name: %s\n' "$1" >&2
        exit 2
        ;;
esac

TEST_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
TEST_DIR="$TEST_ROOT/$1"
if [ ! -d "$TEST_DIR" ]; then
    printf 'No unit test directory for feature: %s\n' "$1" >&2
    exit 1
fi

found=false
for test_file in "$TEST_DIR"/*.sh; do
    [ -f "$test_file" ] || continue
    found=true
    sh "$test_file"
    printf 'PASS %s\n' "${test_file##*/}"
done

if [ "$found" = false ]; then
    printf 'No unit tests found for feature: %s\n' "$1" >&2
    exit 1
fi
