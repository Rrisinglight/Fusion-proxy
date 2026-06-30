#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:-$(cat "$ROOT/VERSION")}"
ARCH=linux-x86_64
URL="https://snapshots.mitmproxy.org/${VERSION}/mitmproxy-${VERSION}-${ARCH}.tar.gz"
TMPDIR="$(mktemp -d)"

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

echo "Installing mitmproxy ${VERSION} (${ARCH})..."
wget -q -O "$TMPDIR/mitmproxy.tar.gz" "$URL"
tar -xzf "$TMPDIR/mitmproxy.tar.gz" -C "$TMPDIR"

for bin in mitmdump mitmproxy mitmweb; do
  install -m 755 "$TMPDIR/$bin" "/usr/local/bin/$bin"
done

echo "Installed:"
mitmdump --version
