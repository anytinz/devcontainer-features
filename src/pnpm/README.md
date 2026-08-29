
# pnpm (pnpm)

Installs pnpm using the official install script from [pnpm/get.pnpm.io](https://github.com/pnpm/get.pnpm.io).

The install script is vendored into the feature as a git submodule rather than downloaded with curl at build time.

This feature requires [common-utils](https://github.com/devcontainers/features/tree/main/src/common-utils) to be installed beforehand (declared via `installsAfter`) because the pnpm install script needs `curl` or `wget` plus `ca-certificates` to download and verify pnpm.

## Example Usage

```json
"features": {
    "ghcr.io/devcontainers/feature-starter/pnpm:1": {
        "version": "latest"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of pnpm to install. Accepts a full version (e.g. 11.24.0), a bare major (e.g. 11), or a dist-tag (e.g. latest, next-12). Maps to the PNPM_VERSION environment variable of the install script. | string | latest |
| pnpmHome | Directory where pnpm is installed. Maps to the PNPM_HOME environment variable of the install script. The default is shared so that the binary stays accessible to every container user. | string | /usr/local/share/pnpm |

## Options Mapping

Each option is forwarded to the corresponding environment variable read by `install.sh`:

| Feature option | Environment variable |
|-----|-----|
| version | PNPM_VERSION |
| pnpmHome | PNPM_HOME |

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/devcontainers/feature-starter/blob/main/src/pnpm/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
