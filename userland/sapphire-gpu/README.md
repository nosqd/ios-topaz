# Sapphire GPU stack integration (source stage)

Source: `Angelpro09xd/ios-sapphire`, branch `sapphire`, commit
`344a8af2a9d5` (2026-10-26). Files here are an additive source snapshot so the
existing topaz GPU path and boot artifacts stay intact. `LICENSE` is the
HackiOS MIT license carried by upstream; Mesa source patches and XNU patches
retain their own upstream notices. The original design notes are in
`UPSTREAM-GPU-ROADMAP.md`.

## What is connected

- `mesa/sapphire-drm/redwood_drm.c` now matches our existing `RedwoodGPU`
  service (XNU patch 0901). The sapphire-only `SapphireGPU` service name was
  changed in this copy. The later Mesa fixes, AIR frontend, and iOS 16.7 EAGL
  bridge are kept together here.
- `metal/SapphireMetal/SapphireMetal.m` waits for `RedwoodGPU` in `sweetgl=1`
  mode. `metal/build.sh` builds the exploratory Metal bundle on this host with
  `/usr/bin/ld64.lld`.
- `mk-mesa.sh` and `build-gl.sh` use a caller-provided iPhoneOS `SDK` and a
  local `build-mesa` work directory by default. Both produce `/redwood` install
  names, which match `userland/gpu/topaz_inject.c` after its path update.

## Still needed before an image can use this stack

1. Mesa 25.0.7, the EAGL bridge, the AIR library and the Metal bundle were
   built on 2026-10-27 with the Theos iPhoneOS 16.5 SDK in `/tmp/hackios-sdk`
   and LLVM 23 in `/usr/bin`. The source patches applied cleanly. The outputs
   are staged in `/tmp/hackios-mega-gpu-stage.tar.xz` with a SHA256 manifest.
   This is a host build, not a runtime verification or a signed install.
   Rebuild with `SDK=/path/to/iPhoneOS.sdk LLVM=/usr/bin B=/tmp/mesa-build
   ./mk-mesa.sh`, then `SDK=... LLVM=/usr/bin M=/tmp/mesa-build/out
   ./build-gl.sh`. `mk-mesa.sh` replaces its own build tree; use a dedicated
   `B` directory. `tools/build-topaz-gpu-loader.sh` builds the iOS 16.7
   backboardd loader, which now loads `/redwood/lib/libredwood-gl.dylib`.
   `tools/stage-sapphire-gpu.sh` packages all dylibs and the optional Metal
   bundle; set `MESA_OUT`, `MESA_BUILD`, `LOADER_OUT`, and optionally
   `METAL_BUNDLE` before running it.
2. The `redwood-drm` request header is byte-identical to our existing one;
   selector numbers match the `RedwoodGPU` kernel, and its optional WC probe
   falls back when unsupported. Buffer cache behavior, surface handling and
   fence waits still need a device runtime test.
3. Put the built `/redwood/lib` and `/topaz/lib` files into a **copy** of the
   iOS root image and connect the chosen injection path. The wrapper is
   packaged under `optional-wrapper/`: replacing `/usr/libexec/backboardd`
   also needs a verified rename of the original and launchd behavior.
   Keep the known-good image as a
   fallback. No install or phone write is performed by this source stage.
4. `SapphireMetal`'s direct `SGPU` client needs XNU patch 0148's ABI on
   `IOAcceleratorES`. Our patch 0138 currently publishes an empty service, so
   the Metal mode must stay disabled. Its `sweetgl=1` fallback is useful only
   after the service advertises the plugin and the EAGL/Mesa path is built.
5. AIR/Metal compilation is research code. It is included to preserve the
   complete upstream GPU source, but is not part of the proven EAGL/freedreno
   route to the iOS home screen.

## Kernel mapping

Upstream GPU patches 0145 and 0148–0154 overlap our 0901–0917 GPU series.
Our `RedwoodGPU` already supplies power-up, firmware, SMMU, msm DRM requests,
async submissions, WC buffers and seqno fences. Upstream 0154's TIMESTAMP bug
does not occur in our 0901 fence event (`CP_EVENT_WRITE` uses event 4 without
bit 30). Further fixes must be compared by behavior, then ported individually.
For 4K/eight-core work, sapphire 0216–0218 correspond to our 0140–0142;
`0952-sapphiren-silver-cpufreq.patch` brings only the silver-domain part of
0219. The current 4K early framebuffer mapping remains `0x5c000000`.

No command in this directory is run against the phone.
