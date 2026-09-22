#!/bin/sh
set -eu

TEST_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
sh "$TEST_DIR/_global/assert_vendor_missing_point.sh" '/^NPM_SIGNING_KEY_ID=/d' NPM_SIGNING_KEY_ID
