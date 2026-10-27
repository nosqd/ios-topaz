# Sapphire UEFI source snapshot

Copied from `Angelpro09xd/ios-sapphire`, branch `sapphire`, commit
`344a8af2a9d5` (2026-10-26). The UEFI code follows the upstream
BSD-2-Clause-Patent terms; see `README.md` and SPDX headers in `files/`.

This is an alternative ABL → BootShim → UEFI → XNU shim chain. The current
sapphiren mega images use the direct ABL → XNU shim chain, so these sources do
not alter either boot image or the HFS+ root image. A UEFI build needs the
Mu-Silicium base and submodules, tapas firmware binaries, and the handset's
live device tree. None is bundled here or generated from the existing boot
images.

`files/Platforms/Xiaomi/sapphirePkg/Library/MemoryMapLib/MemoryMapLib.c`
reserves the panel splash at `0x5c000000`, matching our ADT and 4K XNU early
framebuffer. Its `XNUP` payload base is `0xa0000000`; do not substitute our
root filesystem address or the old upstream framebuffer address for either.
