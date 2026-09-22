#!/bin/sh
set -eu

TEST_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
sh "$TEST_DIR/_global/assert_vendor_missing_point.sh" '/https:\/\/github.com\/pnpm\/pnpm\/releases\/download/d' GitHub-releases-base
