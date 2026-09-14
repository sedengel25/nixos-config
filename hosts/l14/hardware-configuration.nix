# ============================================================================
# PLACEHOLDER — replace this ON the L14 itself, during/after the install:
#
#     sudo nixos-generate-config --root /mnt --show-hardware-config \
#         > /path/to/nixos-config/hosts/l14/hardware-configuration.nix
#
# It will contain that machine's fileSystems (root + the Windows-shared EFI
# partition), boot.initrd modules, CPU microcode, etc. Until you replace this
# file, a build fails with "fileSystems option does not specify your root" —
# that's expected.
# ============================================================================
{ ... }:

{
  imports = [ ];

  # (real hardware config goes here — see the note above)
}
