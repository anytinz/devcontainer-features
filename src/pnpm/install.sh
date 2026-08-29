#!/bin/sh
set -e

echo "Activating feature 'pnpm'"

# The install script is vendored through the 'pnpm/get.pnpm.io' git submodule,
# so no download of the script itself is needed at build time.
FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_SCRIPT="$FEATURE_DIR/vendor/install.sh"

if [ ! -f "$INSTALL_SCRIPT" ]; then
    echo "Error: could not find the pnpm install script at '$INSTALL_SCRIPT'." >&2
    echo "The 'pnpm/get.pnpm.io' git submodule does not appear to be checked out." >&2
    echo "Run 'git submodule update --init --recursive' to fetch it." >&2
    exit 1
fi

# The install script needs curl or wget to download pnpm. Both are provided
# by the common-utils feature, so only libatomic is handled here: pnpm's v11
# binary (a Node.js SEA build) needs it on minimal base images (see
# https://github.com/pnpm/pnpm/issues/11531), while v10 and the v12+ Rust
# binaries don't. The check is unconditional because the resolved major
# isn't known until the install script runs, and a tiny package is cheaper
# than a build that fails on a missing one.
if command -v apt-get > /dev/null 2>&1 && ! ldconfig -p 2>/dev/null | grep -qE 'libatomic\.so\.1[^0-9]'; then
    apt-get update -y
    apt-get install -y --no-install-recommends libatomic1
fi

# Forward the feature options to the install script's environment variables.
export PNPM_VERSION="${VERSION:-latest}"

# The install script's 'pnpm setup' step needs SHELL to infer which shell rc
# file to update, but it is unset inside a dev container build.
if [ -z "${SHELL:-}" ]; then
    if command -v bash > /dev/null 2>&1; then
        export SHELL=/bin/bash
    else
        export SHELL=/bin/sh
    fi
fi

PNPM_HOME="${PNPMHOME:-"$HOME/.pnpm"}"
# The install script does not expand a leading tilde itself, so expand it here.
case "$PNPM_HOME" in
    "~/"*) PNPM_HOME="$HOME${PNPM_HOME#\~}" ;;
esac
export PNPM_HOME

sh "$INSTALL_SCRIPT"

# 'pnpm setup' installs the binary into $PNPM_HOME/bin (or $PNPM_HOME for very
# old versions) and only updates the shell rc files of the root user the
# install script runs as, so link the binary into /usr/local/bin to put it on
# the PATH for every user.
PNPM_BIN=""
if [ -x "$PNPM_HOME/bin/pnpm" ]; then
    PNPM_BIN="$PNPM_HOME/bin/pnpm"
elif [ -x "$PNPM_HOME/pnpm" ]; then
    PNPM_BIN="$PNPM_HOME/pnpm"
fi

if [ -n "$PNPM_BIN" ] && [ ! -e /usr/local/bin/pnpm ]; then
    ln -s "$PNPM_BIN" /usr/local/bin/pnpm
fi

if [ -n "$PNPM_BIN" ]; then
    echo "Installed pnpm $("$PNPM_BIN" --version) to $PNPM_HOME"
fi
