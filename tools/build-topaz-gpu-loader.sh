#!/usr/bin/env bash
# Build the iOS 16.7 backboardd GPU loader and its optional wrapper.
set -euo pipefail

repo=$(cd "$(dirname "$0")/.." && pwd)
sdk=${SDK:?Set SDK to an iPhoneOS SDK path}
llvm=${LLVM:-/usr/bin}
out=${1:-/tmp/hackios-topaz-loader-build}
mkdir -p "$out"

"$llvm/clang" -target arm64-apple-ios16.0 -isysroot "$sdk" -fuse-ld=lld \
    -O2 -Wall -dynamiclib -install_name /topaz/lib/libtopaz-inject.dylib \
    -framework CoreFoundation -framework IOKit -lobjc \
    -o "$out/libtopaz-inject.dylib" "$repo/userland/gpu/topaz_inject.c"
"$llvm/clang" -target arm64-apple-ios16.0 -isysroot "$sdk" -fuse-ld=lld \
    -O2 -Wall -o "$out/backboardd-wrapper" "$repo/userland/gpu/bbd_wrap.c"
file "$out/libtopaz-inject.dylib" "$out/backboardd-wrapper"
