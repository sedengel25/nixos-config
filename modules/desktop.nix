# X11 + i3 desktop environment and the system tools it relies on.
{ pkgs, ... }:

{
  # --- X11 + i3 ---
  services.xserver = {
    enable = true;
    xkb.layout = "de";
    displayManager.lightdm.enable = true;
    displayManager.setupCommands = ''
      ${pkgs.xorg.setxkbmap}/bin/setxkbmap de
    '';
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

  # --- Secret-Service Keyring (gnome-keyring) ---
  # eduVPN & Co. speichern Tokens/Passwörter über die Secret-Service-API.
  # Unter i3 läuft standardmäßig kein Keyring-Daemon. Genau wie auf Arch
  # (pam_gnome_keyring in /etc/pam.d/lightdm) startet & entsperrt PAM den
  # Daemon beim LightDM-Login mit dem Login-Passwort.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true;

  # --- System-Pakete, die die i3-Config aufruft ---
  environment.systemPackages = with pkgs; [
    dex                   # XDG-Autostart
    xss-lock              # Screen-Lock vor Suspend
    networkmanagerapplet  # nm-applet
    flameshot             # Screenshots
    xclip                 # X11-Clipboard-CLI: liest/schreibt die Zwischenablage
                          # (u.a. damit claude-code Bilder aus dem Clipboard
                          # per Strg+V einfügen kann)
    psmisc                # killall
    feh                   # Wallpaper (in Config referenziert)
  ];

  # --- Schriften ---
  fonts.packages = with pkgs; [
    hack-font  # von der Alacritty-Config verwendet
  ];
}
