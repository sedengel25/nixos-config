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
    # ../../modules/eduvpn.nix   # enable if this laptop needs the uni/work VPN

    # System-level user account.
    ../../users/sebi.nix
  ];

  # --- Host identity ---
  networking.hostName = "nixos-l14";

  # --- Bootloader (Dual-Boot mit Windows) ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Die EFI-Partition wird mit Windows geteilt und ist oft nur 100 MB gross.
  # Jede NixOS-Generation legt dort Kernel + initrd ab (~80-120 MB), deshalb
  # die Anzahl der Boot-Eintraege begrenzen. Bei einer grossen ESP (>= 512 MB)
  # kann der Wert erhoeht oder die Zeile geloescht werden.
  boot.loader.systemd-boot.configurationLimit = 3;

  # --- WICHTIG: pro Host, nicht ändern nach Erstinstallation ---
  system.stateVersion = "26.05";
}
