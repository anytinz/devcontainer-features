#!/bin/sh
set -e

echo "Activating feature 'pnpm'"

# Download the official pnpm install script at build time. curl or wget are
# provided by the common-utils feature (declared via installsAfter). The URL
# can be overridden (e.g. with an internal mirror) via the installScriptUrl
# option, which is passed in as the INSTALLSCRIPTURL environment variable.
INSTALL_SCRIPT_URL="${INSTALLSCRIPTURL:-https://get.pnpm.io/install.sh}"
INSTALL_SCRIPT="$(mktemp)"

cleanup() {
    rm -f "$INSTALL_SCRIPT"
}
trap cleanup EXIT INT TERM

if command -v curl > /dev/null 2>&1; then
    curl -fsSL "$INSTALL_SCRIPT_URL" -o "$INSTALL_SCRIPT"
elif command -v wget > /dev/null 2>&1; then
    wget -qO "$INSTALL_SCRIPT" "$INSTALL_SCRIPT_URL"
else
    echo "Error: the pnpm install script needs curl or wget to be downloaded." >&2
    exit 1
fi

if [ ! -s "$INSTALL_SCRIPT" ]; then
    echo "Error: failed to download the pnpm install script from '$INSTALL_SCRIPT_URL'." >&2
    exit 1
fi

# Rewrite variables baked into the install script before running it so
# intranet users can point it at an internal registry. The official script
# hardcodes NPM_REGISTRY, NPM_SIGNING_KEY_ID and NPM_SIGNING_KEY rather than
# reading environment variables, so each is substituted in place. Set the
# npmRegistryUrl, npmSigningKeyId and npmSigningKey options (NPMREGISTRYURL,
# NPMSIGNINGKEYID, NPMSIGNINGKEY) to override them; base64 key material,
# registry URLs and GitHub proxy URLs never contain the '|' delimiter used
# below.
# Strip trailing slashes so a user-provided base URL joins cleanly with the
# '/<pkg>' and '/v${version}' suffixes the install script appends.
normalize_base_url() {
    printf '%s' "$1" | sed 's|/*$||'
}

rewrite_install_var() {
    var="$1"
    value="$2"
    [ -n "$value" ] || return 0
    sed -i "s|^$var=.*|$var=$value|" "$INSTALL_SCRIPT"
    if ! sed -n "s|^$var=||p" "$INSTALL_SCRIPT" | grep -qxF "$value"; then
        echo "Error: could not rewrite $var inside the install script from '$INSTALL_SCRIPT_URL'." >&2
        exit 1
    fi
}

rewrite_install_var NPM_REGISTRY "$(normalize_base_url "${NPMREGISTRYURL:-}")"
rewrite_install_var NPM_SIGNING_KEY_ID "${NPMSIGNINGKEYID:-}"
rewrite_install_var NPM_SIGNING_KEY "${NPMSIGNINGKEY:-}"

# The GitHub releases download base is inlined into 'download' calls (pnpm <
# v12 is distributed from GitHub rather than the registry), so rewrite every
# occurrence as a substring instead of a whole assignment.
GITHUB_RELEASES_BASE="https://github.com/pnpm/pnpm/releases/download"
rewrite_download_base() {
    value="$1"
    [ -n "$value" ] || return 0
    if ! grep -qF "$GITHUB_RELEASES_BASE" "$INSTALL_SCRIPT"; then
        echo "Error: could not find '$GITHUB_RELEASES_BASE' inside the install script from '$INSTALL_SCRIPT_URL'." >&2
        exit 1
    fi
    sed -i "s|$GITHUB_RELEASES_BASE|$value|g" "$INSTALL_SCRIPT"
    if ! grep -qF "$value" "$INSTALL_SCRIPT"; then
        echo "Error: could not rewrite '$GITHUB_RELEASES_BASE' inside the install script from '$INSTALL_SCRIPT_URL'." >&2
        exit 1
    fi
}

rewrite_download_base "$(normalize_base_url "${GITHUBRELEASESBASEURL:-}")"

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
