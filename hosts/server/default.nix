{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../users/sebi.nix
  ];

  # --- Host identity ---
  # Hier ohne "nixos-"-Präfix, damit Hostname und Flake-Attribut übereinstimmen
  # und `nixos-rebuild switch --flake .#server` auch ohne #server funktioniert.
  networking.hostName = "server";

  # --- Bootloader ---
  # Setzt UEFI voraus. Bootet die Kiste nur im BIOS-/Legacy-Modus, stattdessen:
  #   boot.loader.grub = { enable = true; device = "/dev/sda"; };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Ohne Limit füllt jede Generation die ESP mit Kernel + initrd.
  boot.loader.systemd-boot.configurationLimit = 10;

  users.users.sebi.openssh.authorizedKeys.keys = [
    # desktop — SHA256:RTInrQvGX42veuMFqkombsDRVP1wfop1XlOz4K+Z22A
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOy7ZJ7rzkexnG2cioJBXQJLQP28tjPhb5GlKA3e932c desktop"
    # probably x1
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILZLCICmTCCTo02UcQWgynzMbmf3hB9DJNyXaDoH4eVD sbstdngl@yahoo.com"
  ];

  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };

  # --- Speicher ---
  # Kein Swap-Partition nötig: zram komprimiert im RAM. Fängt Lastspitzen ab,
  # bevor der OOM-Killer zuschlägt.
  zramSwap.enable = true;

  # --- Aufräumen ---
  # Ein Server wird selten angefasst; ohne GC laufen alte Generations die
  # Platte voll, und journald kennt von sich aus keine Obergrenze.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;
  services.journald.extraConfig = "SystemMaxUse=500M";

  # Neue Dienste brauchen hier ihren Port — die Firewall ist per default an
  # und offen ist nur 22 (das öffnet das openssh-Modul selbst).
  # networking.firewall.allowedTCPPorts = [ 80 443 ];

  # --- WICHTIG: pro Host, nicht ändern nach Erstinstallation ---
  system.stateVersion = "26.05";
}
