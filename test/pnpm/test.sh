#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'pnpm' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# Thus, the value of all options will fall back to the default value in
# the Feature's 'devcontainer-feature.json'.
# For the 'pnpm' feature, that means version 'latest' installed to '~/.pnpm'.
#
# These scripts are run as 'root' by default. Although that can be changed
# with the '--remote-user' flag.
#
# This test can be run with the following command:
#
#    devcontainer features test \
#                   --features pnpm \
#                   --remote-user root \
#                   --skip-scenarios \
#                   --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
#                   /path/to/this/repo

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]
check "pnpm is on the PATH" bash -c "command -v pnpm"
check "pnpm reports a version" bash -c "pnpm --version"
check "pnpm is linked into /usr/local/bin" bash -c "[ -L /usr/local/bin/pnpm ]"
check "pnpm symlink points into PNPM_HOME/bin" bash -c "readlink /usr/local/bin/pnpm | grep -q '/bin/pnpm$'"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
