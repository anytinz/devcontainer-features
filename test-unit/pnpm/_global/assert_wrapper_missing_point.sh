#!/bin/sh
set -eu

TEST_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
ROOT="$(CDPATH= cd -- "$TEST_DIR/../.." && pwd)"
FIXTURE_DIR="$(mktemp -d)"
trap 'rm -rf "$FIXTURE_DIR"' EXIT HUP INT TERM
mkdir -p "$FIXTURE_DIR/feature/vendor" "$FIXTURE_DIR/bin"
cp "$ROOT/src/pnpm/install.sh" "$FIXTURE_DIR/feature/install.sh"

cat > "$FIXTURE_DIR/original-installer" <<'INSTALLER'
#!/bin/sh
NPM_REGISTRY='https://registry.npmjs.org'
NPM_SIGNING_KEY_ID='original-id'
NPM_SIGNING_KEY='original-key'
RELEASE_URL='https://github.com/pnpm/pnpm/releases/download/v1/pnpm'
: > "$CAPTURE_FILE"
INSTALLER
sed "$1" "$FIXTURE_DIR/original-installer" > "$FIXTURE_DIR/feature/vendor/install.sh"
if cmp -s "$FIXTURE_DIR/original-installer" "$FIXTURE_DIR/feature/vendor/install.sh"; then
    printf 'Could not remove %s from the installer fixture\n' "$3" >&2
    exit 1
fi

# Keep the wrapper from installing libatomic on hosts without it.
cat > "$FIXTURE_DIR/bin/ldconfig" <<'LDCONFIG'
#!/bin/sh
printf 'libatomic.so.1 (libc6)\n'
LDCONFIG
chmod +x "$FIXTURE_DIR/bin/ldconfig"

if CAPTURE_FILE="$FIXTURE_DIR/result" \
   VERSION=11 \
   PNPMHOME="$FIXTURE_DIR/pnpm" \
   NPMREGISTRYURL=https://mirror.example/npm/ \
   NPMSIGNINGKEYID=SHA256:example \
   NPMSIGNINGKEY=ZXhhbXBsZQ== \
   GITHUBRELEASESBASEURL=https://mirror.example/releases/ \
   PATH="$FIXTURE_DIR/bin:$PATH" \
       sh "$FIXTURE_DIR/feature/install.sh" > "$FIXTURE_DIR/stdout" 2> "$FIXTURE_DIR/stderr"; then
    printf 'Wrapper accepted installer without %s\n' "$3" >&2
    exit 1
fi
if ! grep -Fq "$2" "$FIXTURE_DIR/stderr"; then
    cat "$FIXTURE_DIR/stderr" >&2
    printf 'Wrapper failed for a reason other than missing %s\n' "$3" >&2
    exit 1
fi
if [ -e "$FIXTURE_DIR/result" ]; then
    printf 'Wrapper ran installer without %s\n' "$3" >&2
    exit 1
fi
