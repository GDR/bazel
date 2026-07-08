#!/usr/bin/env bash
set -euo pipefail

# Find workspace root
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

# Check if Nix is installed
if ! command -v nix-build &>/dev/null; then
  echo "Error: Nix is not installed or not in PATH." >&2
  exit 1
fi

echo "Generating Linux x86-64 sysroot..."

# Build sysroot in Nix store
STORE_PATH=$(nix-build --no-out-link - <<'NIX'
with import <nixpkgs> {};
runCommand "linux-x86-64-sysroot" {} ''
  mkdir -p $out/usr/include
  mkdir -p $out/usr/lib
  mkdir -p $out/lib

  # Copy glibc headers
  cp -rL ${glibc.dev}/include/. $out/usr/include/
  chmod -R u+w $out/usr/include

  # Copy linux kernel headers
  cp -rL ${linuxHeaders}/include/. $out/usr/include/
  chmod -R u+w $out/usr/include

  # Copy glibc libraries (libc.so, libm.so, crt1.o, etc.)
  cp -rL ${glibc}/lib/. $out/usr/lib/
  chmod -R u+w $out/usr/lib

''
NIX
)

# Copy store path to local directory
rm -rf sysroot/linux-x86_64/usr sysroot/linux-x86_64/lib
mkdir -p sysroot/linux-x86_64
cp -rL "$STORE_PATH"/* sysroot/linux-x86_64/
chmod -R u+w sysroot/linux-x86_64/

# Rewrite absolute glibc paths in linker scripts to be relative to the sysroot
find sysroot/linux-x86_64/usr/lib -type f -name "*.so" -exec sed -i -E 's|/nix/store/[a-z0-9]+-glibc-[^/]*/lib/|/usr/lib/|g' {} +

echo "Sysroot generated successfully in sysroot/linux-x86_64/"
