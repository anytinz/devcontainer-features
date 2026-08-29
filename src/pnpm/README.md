
# pnpm (pnpm)

Installs pnpm using the official install script from pnpm/get.pnpm.io

## Example Usage

```json
"features": {
    "ghcr.io/anytinz/devcontainer-features/pnpm:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of pnpm to install. Accepts a full version (e.g. 11.24.0), a bare major (e.g. 11), or a dist-tag (e.g. latest, next-12). Maps to the PNPM_VERSION environment variable of the install script. | string | latest |
| pnpmHome | Directory where pnpm is installed. Maps to the PNPM_HOME environment variable of the install script. The default is shared so that the binary stays accessible to every container user. | string | /usr/local/share/pnpm |
| installScriptUrl | URL of the pnpm install script to download at build time. Point this at an internal mirror of the script when the default URL is unreachable (e.g. for intranet users). | string | https://get.pnpm.io/install.sh |
| npmRegistryUrl | npm registry used to download the pnpm binary. When set, the NPM_REGISTRY value inside the downloaded install script is rewritten with this URL before it runs. Useful with intranet mirrors such as https://registry.npmmirror.com. | string | - |
| npmSigningKeyId | The npm registry signing key ID the install script must find on downloaded packages. Override when your registry re-signs packages with its own key (e.g. a private Nexus repository): the NPM_SIGNING_KEY_ID value inside the downloaded install script is rewritten with it. Leave empty to keep the official npm registry key. | string | - |
| npmSigningKey | The base64 npm registry signing public key used to verify downloads. Override together with npmSigningKeyId when your registry signs packages with its own key: the NPM_SIGNING_KEY value inside the downloaded install script is rewritten with it. Leave empty to keep the official npm registry key. | string | - |
| githubReleasesBaseUrl | Base URL for downloading pnpm binaries from GitHub releases (used by the install script for pnpm < v12). When set, every occurrence of https://github.com/pnpm/pnpm/releases/download inside the downloaded install script is replaced with it, so binaries can be fetched through a GitHub proxy mirror. Trailing slashes are stripped automatically. Leave empty to keep the official GitHub URL. | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/anytinz/devcontainer-features/blob/main/src/pnpm/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
