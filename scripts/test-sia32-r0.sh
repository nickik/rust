#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-$HOME/alltech/DigitalEquipment}"
RUST="${RUST_REPO:-$ROOT/rust}"
RUST_SIA="${RUST_SIA_REPO:-$ROOT/rust-sia}"
HOST="${HOST:-x86_64-unknown-linux-gnu}"
STAGE1="$RUST/build/$HOST/stage1"
CARGO_NIGHTLY="${CARGO_NIGHTLY:-$HOME/.local/share/rustup/toolchains/nightly-2026-09-11-$HOST/bin/cargo}"

unset RUSTC RUSTDOC RUSTFLAGS RUSTFLAGS_BOOTSTRAP CARGO_TARGET_DIR

cd "$RUST"
./x build --stage 1 library \
  --target "$HOST" \
  --set llvm.download-ci-llvm=false \
  --set 'rust.codegen-backends=["llvm","cranelift"]'

test -x "$STAGE1/bin/rustc"
test -f "$STAGE1/lib/rustlib/$HOST/lib/"libstd-*.rlib || true
find "$STAGE1/lib/rustlib/$HOST/codegen-backends" -maxdepth 1 -type f -print

mkdir -p "$STAGE1/lib/rustlib/src/rust"
ln -sfn "$RUST/library" "$STAGE1/lib/rustlib/src/rust/library"

cd "$RUST_SIA"
export RUSTC="$STAGE1/bin/rustc"
export RUSTDOC="$STAGE1/bin/rustdoc"
export RUSTFLAGS="-Zcodegen-backend=cranelift"

rm -rf examples/r0-add/target

"$CARGO_NIGHTLY" build \
  -Zjson-target-spec \
  -Zbuild-std=core \
  -Zbuild-std-features=compiler-builtins-mem \
  --manifest-path examples/r0-add/Cargo.toml \
  --target "$RUST_SIA/targets/sia32-unknown-none.json" \
  -j1
