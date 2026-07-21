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

    # System-level user account.
    ../../users/sebi.nix
  ];

  # --- Host identity ---
  networking.hostName = "nixos-desktop";

  # --- Bootloader (Dual-Boot mit Windows) ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- WICHTIG: pro Host, nicht ändern nach Erstinstallation ---
  system.stateVersion = "26.05";
}
