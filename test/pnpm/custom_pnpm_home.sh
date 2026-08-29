#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'pnpmHome' option maps to the PNPM_HOME environment variable.
# 'pnpm setup' installs the binary into $PNPM_HOME/bin.
check "pnpm is installed to the custom PNPM_HOME" bash -c "[ -x /usr/local/share/pnpm/bin/pnpm ] || [ -x /usr/local/share/pnpm/pnpm ]"
check "pnpm symlink points at the custom PNPM_HOME" bash -c "readlink /usr/local/bin/pnpm | grep -q '^/usr/local/share/pnpm'"

# Report results
reportResults
