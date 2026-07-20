# ============================================================================
# PLACEHOLDER — do NOT commit real machine settings from your Arch box here.
#
# On the actual NixOS x1 machine, generate the real file and drop it in place:
#
#     sudo nixos-generate-config --show-hardware-config \
#         > /path/to/nixos-config/hosts/x1/hardware-configuration.nix
#
# It will contain that machine's fileSystems, boot.initrd modules, CPU
# microcode, etc. Until you replace this file, a build will fail with a
# "fileSystems option does not specify your root" error — that's expected.
# ============================================================================
{ ... }:

{
  imports = [ ];

  # (real hardware config goes here — see the note above)
}
