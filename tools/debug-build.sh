#!/usr/bin/env bash
# Build a Bazel cc_binary/rust_binary with debug symbols usable by LLDB/GDB.
# Works on both macOS and Linux.
# Usage: ./tools/debug-build.sh //package:target
set -euo pipefail

TARGET="${1:?Usage: $0 //package:target}"
BIN_PATH="${TARGET#//}"
BIN_PATH="${BIN_PATH/://}"
BIN_NAME="$(basename "${BIN_PATH}")"

echo "==> Building ${TARGET} with debug symbols..."
bazelisk build --config=dbg "${TARGET}"

mkdir -p .debug
cp -f "bazel-bin/${BIN_PATH}" ".debug/${BIN_NAME}"

case "$(uname -s)" in
    Darwin)
        # macOS: debug info lives in .o files, not the binary.
        # dsymutil bundles it into a .dSYM for LLDB.
        echo "==> Creating dSYM bundle (macOS)..."
        dsymutil ".debug/${BIN_NAME}"
        ;;
    Linux)
        # Linux: DWARF debug info is embedded in the ELF binary.
        # No extra steps needed.
        echo "==> Debug info embedded in binary (Linux)."
        ;;
esac

# Point .debug/current at the just-built binary so launch.json
# doesn't need to know the target name.
ln -sf "${BIN_NAME}" ".debug/current"
if [ -d ".debug/${BIN_NAME}.dSYM" ]; then
    rm -rf ".debug/current.dSYM"
    cp -R ".debug/${BIN_NAME}.dSYM" ".debug/current.dSYM"
fi

# Write LLDB source-map command so launch.json doesn't need
# a hardcoded execroot path.
EXECROOT="$(bazelisk info execution_root 2>/dev/null)"
echo "settings set target.source-map \"${EXECROOT}\" \"$(pwd)\"" > .debug/source-map.lldb

echo "==> Done: .debug/${BIN_NAME} (also .debug/current)"
