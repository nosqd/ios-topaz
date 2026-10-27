#!/usr/bin/env bash
# Package host-built Sapphire Mesa/EAGL/AIR binaries without changing an iOS image.
set -euo pipefail

repo=$(cd "$(dirname "$0")/.." && pwd)
gpu="$repo/userland/sapphire-gpu"
mesa_out=${MESA_OUT:?Set MESA_OUT to the Mesa build out directory}
mesa_build=${MESA_BUILD:?Set MESA_BUILD to the Mesa build directory}
metal_bundle=${METAL_BUNDLE:-$gpu/metal/out/SapphireMetal.bundle}
out=${1:-/tmp/hackios-mega-gpu-stage}
stage="$out/redwood/lib"

mkdir -p "$stage"
install -m 0755 "$mesa_out/libOSMesa.8.dylib" "$stage/libOSMesa.8.dylib"
install -m 0755 "$gpu/obj/libredwood-gl.dylib" "$stage/libredwood-gl.dylib"
install -m 0755 "$mesa_build/src/gallium/drivers/freedreno/libredwoodair.dylib" "$stage/libredwoodair.dylib"

if [[ -f "$metal_bundle/SapphireMetal" ]]; then
    mkdir -p "$out/optional-metal"
    cp -a "$metal_bundle" "$out/optional-metal/"
fi

(
    cd "$out"
    sha256sum redwood/lib/*.dylib > SHA256SUMS
    if [[ -f optional-metal/SapphireMetal.bundle/SapphireMetal ]]; then
        sha256sum optional-metal/SapphireMetal.bundle/SapphireMetal >> SHA256SUMS
    fi
    sha256sum -c SHA256SUMS
    paths=(redwood SHA256SUMS)
    [[ ! -d optional-metal ]] || paths+=(optional-metal)
    tar -cJf "$out.tar.xz" "${paths[@]}"
)
echo "$out.tar.xz"
