{ ... }:

{
  imports = [
    # Per-machine hardware — generated ON this machine, see the placeholder file.
    ./hardware-configuration.nix

    # Nur die Basis: kein desktop.nix (X11/i3/LightDM), kein audio.nix,
    # bluetooth.nix oder eduvpn.nix — die Kiste läuft headless.
    ../../modules/common.nix

    # System-level user account.
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

  # --- SSH: nur Public-Key-Login ---
  # Der Key steht bewusst HIER und nicht in users/sebi.nix: die Datei
  # importieren alle drei Hosts, ein Key dort würde also auch x1 und desktop
  # ändern. Public Keys sind nicht geheim und dürfen ins Repo.
  # Ohne passenden Key sperrst du dich aus und kommst nur noch per
  # Monitor+Tastatur an die Konsole.
  users.users.sebi.openssh.authorizedKeys.keys = [
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
