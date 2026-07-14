{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # --- Bootloader (Dual-Boot mit Windows) ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- Netzwerk ---
  networking.hostName = "nixos-x1";
  networking.networkmanager.enable = true;

  # --- Zeitzone & Locale ---
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";

  # --- X11 + i3 ---
  services.xserver = {
    enable = true;
    xkb.layout = "de";
    displayManager.lightdm.enable = true;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
        i3blocks
      ];
    };
  };

  # --- Audio (PipeWire, ersetzt PulseAudio, pactl funktioniert weiterhin) ---
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  # --- Bluetooth ---
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # --- User ---
  users.users.sebi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.bash;
  };

  # --- SSH (praktisch fürs Rüberschieben von Configs) ---
  services.openssh.enable = true;

  # --- Programme, die deine i3-Config aufruft ---
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    # i3-Umgebung
    alacritty          # Terminal
    rofi               # Launcher
    dex                # XDG-Autostart
    xss-lock           # Screen-Lock vor Suspend
    networkmanagerapplet  # nm-applet
    flameshot          # Screenshots
    psmisc             # killall
    feh                # Wallpaper (in Config referenziert)

    # Deine Apps
    evolution          # Mail
    nautilus           # Dateimanager
    dbeaver-bin        # Datenbank-GUI

    # Basics
    git
    vim
    wget
  ];

  # --- WICHTIG: nicht ändern nach Erstinstallation ---
  system.stateVersion = "26.05";
}
