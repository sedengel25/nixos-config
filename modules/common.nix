# Baseline every host imports
{ pkgs, ... }:

{
  # Enable flakes + the new nix CLI (nix build, nix run, nix develop...)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow 'unfree' software (claude-code, positron, NVIDIA-Treiber …)
  # Unfree: licensed in a way that restricts use, redistribution or modification
  nixpkgs.config.allowUnfree = true;

  # --- Networking ---
  # Enables NetworkManager, which:
  #   - installs the program and starts it automatically at boot (systemctl status NetworkManager)
  #   - writes its configuration files (/etc/NetworkManager/NetworkManager.conf)
  #   - creates a user group that is allowed to change network settings (group "networkmanager" in /etc/group)
  #   - installs the helper programs it needs for WiFi
  #   - switches off other programs that would compete for the same interfaces
  # The tray icon and the commands nmcli and nmtui talk to this program.
  # Saved WiFi networks and passwords live in /etc/NetworkManager/system-connections/ (root only).
  networking.networkmanager.enable = true;

  # --- TimeZone + Keyboard ---
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";

  # --- SSH daemon ---
  #   - adds openssh to the system
  #   - creates a systemd unit that starts sshd daemon at boot
  #   - generates host keys on first activation
  #   - opens the firewall port for SSH, but only if you also have networking.firewall.enable = true
  services.openssh.enable = true;

  # --- dconf ---
  #  - installs the dconf package and its daemon
  #  - set up the D-Bus service that lets applications read and write their settings
  #  - provides the backend that tools like dconf-editor or gsettings use
  programs.dconf.enable = true;

  # --- CLI tools ---
  environment.systemPackages = with pkgs; [
    # Version control / editor
    git
    vim

    # Development / interactive computing
    jupyter   # notebook environment (Python/R/etc.)
    gdb       # debugger for compiled programs (C/C++)

    # Network / download
    wget

    # File & search utilities
    file      # detects file type by content
    lsof      # lists open files and holding processes
    # Fast search tools. Note: the `fd` binary is called `fd`
    # (not `fdfind` as on Debian/Ubuntu); ripgrep provides `rg`.
    fd        # fast find replacement
    ripgrep   # fast grep replacement (rg)

    # Archives: pack/unpack
    zip
    unzip
    p7zip     # 7z / 7za

    # Hardware info
    pciutils  # provides `lspci` (list PCI devices)
    usbutils  # provides `lsusb` (list USB devices)
    lshw      # detailed hardware listing

    # VM
    qemu

    # Mount
    cifs-utils  # mount Windows/SMB network shares

    # Geo
    gdal      # read/write/convert geospatial data (raster/vector)
    gpsbabel  # convert between GPS data formats
  ];
}
