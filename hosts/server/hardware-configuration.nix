# ============================================================================
# PLACEHOLDER — wird auf der echten Maschine ersetzt.
#
# Beim Installieren von der NixOS-ISO, nach dem Mounten von /mnt und /mnt/boot:
#
#     nixos-generate-config --root /mnt --show-hardware-config \
#         > hosts/server/hardware-configuration.nix
#     git add hosts/server/hardware-configuration.nix
#
# Danach enthält die Datei fileSystems, boot.initrd-Module, CPU-Microcode usw.
# dieser Maschine. Solange dieser Platzhalter drinsteht, scheitert ein Build
# mit "fileSystems option does not specify your root" — das ist erwartet.
#
# `git add` nicht vergessen: Flakes sehen nur Dateien, die Git kennt.
# ============================================================================
{ ... }:

{
  imports = [ ];

  # (echte Hardware-Config kommt hierhin — siehe oben)
}
