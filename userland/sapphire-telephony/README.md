# Sapphire telephony source (offline stage)

Source: `Angelpro09xd/ios-sapphire`, branch `sapphire`, commit
`344a8af2a9d5` (2026-10-26). The five C sources are copied without
functional changes; `build.sh` uses caller-provided `SDK`, `LLVM` and `OUT`
paths. This directory is not installed in the current mega root image.

Build on the host:

```sh
SDK=/path/to/iPhoneOS.sdk LLVM=/usr/bin OUT=/tmp/sapphire-telephony-build ./build.sh
```

The host build on 2026-10-27 produced arm64 `qmitool`, `ccbridge.dylib`,
`ccstart` and `pdpnet` with LLVM 23 and the iPhoneOS 16.5 SDK. Compilation
alone does not prove that they can use this image's modem.

The tools depend on Sapphire's kernel QMI and IPA/pdp chain (patches
0220, 0222 and 0225–0232), an ADT `/baseband` node, and root-image launchd
changes. None of those dependencies is present in the current boot/root
artifacts. Sapphire's current installation loads `ccbridge` through
CommCenter's weak `/usr/appleinternal/lib/liblinkguard.dylib` dependency;
its notes say the older `ccstart` launchd wrapper caused a launchd panic.
Do not install these binaries into the image before the kernel and root
integration is complete.

Sapphire's 0233 fixed low-memory framebuffer pool at `0xe2000000` overlaps
the earlier 4K boot's kernel-managed RAM window, `0xb0000000`–`0xfd000000`.
XNU patch 0958 adapts it for a new 4K ADT with RAM wholly above 4 GiB;
the older 4K boot must retain its older kernel. Patch 0234's independent
early display-off handling is ported as XNU patch 0957.
