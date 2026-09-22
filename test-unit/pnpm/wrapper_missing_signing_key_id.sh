#!/bin/sh
set -eu

TEST_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
sh "$TEST_DIR/_global/assert_wrapper_missing_point.sh" '/^NPM_SIGNING_KEY_ID=/d' 'could not rewrite NPM_SIGNING_KEY_ID inside the vendored pnpm install script' NPM_SIGNING_KEY_ID
