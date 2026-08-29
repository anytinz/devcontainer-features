#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'version' option maps to the PNPM_VERSION environment variable.
# A bare major asks the install script to resolve the latest release of that major.
check "pnpm major version is 11" bash -c "pnpm --version | grep -q '^11\.'"

# Report results
reportResults
