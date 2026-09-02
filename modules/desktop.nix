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

  # --- Secret-Service Keyring ---
  #   - installs and enables the gnome-keyring daemon
  #   - daemon securely stores secrets: Wi-Fi passwords, SSH key passphrases, GPG keys, app tokens (browsers, email clients, etc.)
  #   - implements the Secret Service D-Bus API, so apps like Chromium, Firefox, Evolution, or NetworkManager can store/retrieve credentials through it instead of managing their own encrypted storage
  services.gnome.gnome-keyring.enable = true;
  #    - hooks gnome-keyring into the PAM stack specifically for the lightdm login service: writes 'pam_gnome_keyring.so' into auth and session management of /etc/pam.d/login (which is called by /etc/pam.d/lightdm)
  #    - on login, PAM unlocks your gnome-keyring using the same password you typed to log in, so you don't get a second separate "unlock keyring" prompt after login
  security.pam.services.lightdm.enableGnomeKeyring = true;

  # --- Packages needed by i3 ---
  environment.systemPackages = with pkgs; [
    dex                   # runs XDG .desktop autostart entries on login
    xss-lock              # locks the screen automatically before suspend
    networkmanagerapplet  # tray applet for NetworkManager (nm-applet), Wi-Fi/VPN UI
    flameshot             # screenshot tool with annotation features
    xclip                 # CLI to read/write the X11 clipboard
    psmisc                # process utilities, provides `killall`, `fuser`, `pstree`
    feh                   # lightweight image viewer, used here to set the wallpaper
  ];

  # --- Fonts ---
  fonts.packages = with pkgs; [
    hack-font  # specified in ~/.config/alacritty/alacritty.toml 
  ];
}
