#!/bin/bash
# Offline build of Sapphire telephony tools. The kernel/ADT and root-image
# integration must be completed separately before these binaries can be used.
set -euo pipefail
cd "$(dirname "$0")"
SDK=${SDK:?Set SDK to an iPhoneOS SDK path}
L=${LLVM:-/usr/bin}
OUT=${OUT:-/tmp/hackios-sapphire-telephony-build}
mkdir -p "$OUT"
"$L/clang" -target arm64-apple-ios16.0 -isysroot "$SDK" -fuse-ld=lld -O2 -Wall -Wextra -Wno-unused-parameter \
	-o "$OUT/qmitool" qmitool.c
echo "$OUT/qmitool"
# ccbridge.dylib: loaded into CommCenter (DYLD_INSERT_LIBRARIES), installed as /redwood/lib/ccbridge.dylib
"$L/clang" -target arm64-apple-ios16.0 -isysroot "$SDK" -fuse-ld=lld -O2 -Wall -Wextra -Wno-unused-parameter \
	-dynamiclib -install_name /redwood/lib/ccbridge.dylib -framework CoreFoundation -framework IOKit -o "$OUT/ccbridge.dylib" ccbridge.c
echo "$OUT/ccbridge.dylib"
# ccstart: CommCenter's launchd Program (/redwood/bin/ccstart), sets DYLD_INSERT_LIBRARIES and execs it
"$L/clang" -target arm64-apple-ios16.0 -isysroot "$SDK" -fuse-ld=lld -O2 -Wall -o "$OUT/ccstart" ccstart.c
echo "$OUT/ccstart"
# pdpnet: the data call's IPv4 + DNS published to configd (/var/root/pdpnet, run by qmitool datacall)
"$L/clang" -target arm64-apple-ios16.0 -isysroot "$SDK" -fuse-ld=lld -O2 -Wall -Wextra -Wno-unused-parameter \
	-framework CoreFoundation -framework SystemConfiguration -framework CoreTelephony -o "$OUT/pdpnet" pdpnet.c
echo "$OUT/pdpnet"
