#!/bin/sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT HUP INT TERM
mkdir -p "$TEST_DIR/feature/vendor" "$TEST_DIR/bin"
cp "$ROOT/src/pnpm/install.sh" "$TEST_DIR/feature/install.sh"

cat > "$TEST_DIR/feature/vendor/install.sh" <<'INSTALLER'
#!/bin/sh
NPM_REGISTRY='https://registry.npmjs.org'
NPM_SIGNING_KEY_ID='original-id'
NPM_SIGNING_KEY='original-key'
RELEASE_URL='https://github.com/pnpm/pnpm/releases/download/v1/pnpm'
{
    printf 'version=%s\n' "$PNPM_VERSION"
    printf 'home=%s\n' "$PNPM_HOME"
    printf 'registry=%s\n' "$NPM_REGISTRY"
    printf 'key_id=%s\n' "$NPM_SIGNING_KEY_ID"
    printf 'key=%s\n' "$NPM_SIGNING_KEY"
    printf 'release=%s\n' "$RELEASE_URL"
} > "$CAPTURE_FILE"
INSTALLER
cp "$TEST_DIR/feature/vendor/install.sh" "$TEST_DIR/original-installer"

# Avoid package installation on minimal hosts during this wrapper test.
cat > "$TEST_DIR/bin/ldconfig" <<'LDCONFIG'
#!/bin/sh
printf 'libatomic.so.1 (libc6)\n'
LDCONFIG
chmod +x "$TEST_DIR/bin/ldconfig"

CAPTURE_FILE="$TEST_DIR/result" \
VERSION=11 \
PNPMHOME="$TEST_DIR/pnpm" \
INSTALLSCRIPTURL=file:///does-not-exist \
NPMREGISTRYURL=https://mirror.example/npm/ \
NPMSIGNINGKEYID=SHA256:example \
NPMSIGNINGKEY=ZXhhbXBsZQ== \
GITHUBRELEASESBASEURL=https://mirror.example/releases/ \
PATH="$TEST_DIR/bin:$PATH" \
    sh "$TEST_DIR/feature/install.sh"

grep -Fqx 'version=11' "$TEST_DIR/result"
grep -Fqx "home=$TEST_DIR/pnpm" "$TEST_DIR/result"
grep -Fqx 'registry=https://mirror.example/npm' "$TEST_DIR/result"
grep -Fqx 'key_id=SHA256:example' "$TEST_DIR/result"
grep -Fqx 'key=ZXhhbXBsZQ==' "$TEST_DIR/result"
grep -Fqx 'release=https://mirror.example/releases/v1/pnpm' "$TEST_DIR/result"
cmp "$TEST_DIR/original-installer" "$TEST_DIR/feature/vendor/install.sh"
