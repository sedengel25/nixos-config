{ ... }:

{
  imports = [
    # Per-machine hardware — generated ON this machine, see the placeholder file.
    ./hardware-configuration.nix

    # Shared, reusable modules (toggle per host by including/excluding them).
    ../../modules/common.nix
    ../../modules/desktop.nix
    ../../modules/audio.nix
    ../../modules/bluetooth.nix
    ../../modules/eduvpn.nix   
    ../../modules/tailscale.nix
    ../../modules/syncthing.nix

    # System-level user account.
    ../../users/sebi.nix
  ];

  # --- Host identity ---
  networking.hostName = "nixos-l14";

  # --- Bootloader (Dual-Boot mit Windows) ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Die EFI-Partition (260 MB) wird mit Windows geteilt. Gemessen auf dem x1,
  # das die gleiche Konstellation hat: Windows-Bootloader 32 MB, pro Kernel-Satz
  # 13 MB (bzImage) + 41 MB (initrd) = 54 MB. Bleiben ~227 MB fuer NixOS, also
  # Platz fuer rund 4 Kernel-Saetze — deshalb das Limit.
  #
  # Achtung: Das Limit zaehlt Boot-EINTRAEGE, der Platzbedarf haengt aber an der
  # Zahl UNTERSCHIEDLICHER Kernel. Generationen mit gleichem Kernel teilen sich
  # Kernel und initrd auf der ESP und kosten fast nichts extra.
  boot.loader.systemd-boot.configurationLimit = 3;

  # --- WICHTIG: pro Host, nicht ändern nach Erstinstallation ---
  system.stateVersion = "26.05";
}
