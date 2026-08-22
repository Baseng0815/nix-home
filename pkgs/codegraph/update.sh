#!/usr/bin/env nix
#!nix shell --ignore-environment nixpkgs#cacert nixpkgs#coreutils nixpkgs#curl nixpkgs#gawk nixpkgs#gnused nixpkgs#jq nixpkgs#bash --command bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

REPO="colbymchenry/codegraph"

# The releases/latest redirect gives the newest tag without an API token.
TAG="${1:-$(curl -fsSL -o /dev/null -w '%{url_effective}' \
  "https://github.com/$REPO/releases/latest" | sed 's#.*/tag/##')}"

SUMS="$(curl -fsSL "https://github.com/$REPO/releases/download/$TAG/SHA256SUMS")"

sum() {
  printf '%s\n' "$SUMS" | awk -v f="codegraph-$1.tar.gz" '$2 == f { print $1 }'
}

jq -n \
  --arg version "${TAG#v}" \
  --arg linux_x64 "$(sum linux-x64)" \
  --arg linux_arm64 "$(sum linux-arm64)" \
  '{
    version: $version,
    platforms: { "linux-x64": $linux_x64, "linux-arm64": $linux_arm64 }
  }' >manifest.json
