# Baseline every host imports
{ pkgs, inputs, ... }:

let
  # Einzelne Pakete aus 25.11 (siehe input `nixpkgs-2511` in flake.nix).
  pkgs2511 = inputs.nixpkgs-2511.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  # quarto 1.7.34 statt 1.9.37 aus 26.05 (Begruendung am input).
  # Wichtig: pandoc/deno/typst/dart-sass muessen aus DERSELBEN nixpkgs kommen,
  # quarto verdrahtet sie fest im Wrapper -> nicht einzeln auf 26.05 ziehen.
  #
  # rWrapper/python3 = null: quarto baut sonst ein eigenes R (nur rmarkdown!)
  # und ein eigenes Python dazu (906 MiB statt 118 MiB Download). Mit null
  # nimmt quarto R und python vom PATH -> genau die Umgebung aus home/sebi.nix
  # inkl. rEnvPackages, statt eines zweiten, fast leeren R.
  quarto-pinned = pkgs2511.quarto.override {
    rWrapper = null;
    python3 = null;
  };
in

{
  # Enable flakes + the new nix CLI (nix build, nix run, nix develop...)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow 'unfree' software (claude-code, positron, NVIDIA-Treiber …)
  # Unfree: licensed in a way that restricts use, redistribution or modification
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "electron-41.10.7" ];

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
    # Nix
    nix-index
    # Version control / editor
    git
    vim

    # Development / interactive computing
    jupyter   # notebook environment (Python/R/etc.)
    gdb       # debugger for compiled programs (C/C++)

    # Network / download
    wget
    nmap

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

    rdfind # finds duplicated files
    # VM
    qemu


    # Partitioning
    parted
    # Mount
    cifs-utils  # mount Windows/SMB network shares
    ntfs3g

    # Geo
    gdal      # read/write/convert geospatial data (raster/vector)
    gpsbabel  # convert between GPS data formats

    # Presentations
    quarto-pinned
    # texliveMedium + alles, was ~/bda-templates zusaetzlich braucht (ermittelt
    # per kpsewhich ueber alle .tex/.sty/.cls der Templates). Kostet nur ~38 MiB;
    # texliveFull waere 1.0 GiB. Fehlt spaeter ein Paket: `kpsewhich foo.sty`
    # sagt es, dann hier den CTAN-Namen ergaenzen.
    (texliveMedium.withPackages (ps: with ps; [
      # TU-Dresden-Corporate-Design-Klassen (tudscrreprt/tudscrartcl)
      tudscr
      # Literaturverzeichnisse: texliveMedium bringt nur bibtex mit, die
      # Templates wollen biblatex mit biber-Backend (student report: style=apa)
      biblatex
      biber
      biblatex-apa
      # Code-Listings aus pandoc/quarto (Shaded/Highlighting) bzw. minted
      framed
      fvextra
      minted            # braucht pygmentize auf dem PATH (kommt mit jupyter)
      # Schriften/Mathe des TUD-CD-Beamer-Themes
      notomath
      noto
      mnsymbol
      fontaxes          # transitive Abhaengigkeit von notomath
      newtx             # liefert newtxmath.sty (von notomath geladen)
      upquote           # gerade Quotes in Verbatim (pandoc-Listings)
      # Beamer-Extras
      appendixnumberbeamer
      textpos
      transparent
      # Satz/Struktur
      acronym
      comment
      csquotes
      enumitem
      isodate
      pdfcomment
      pgfplots
      placeins
      qrcode
      relsize
      scrhack
      scrwfile
      bigfoot           # liefert suffix.sty (Student-Report-Template)
      mwe               # example-image-* Platzhalterbilder der Demo-Dokumente
      tocloft
      xurl
      zref              # liefert auch zref-savepos.sty
      # Blindtext fuer die Beispieldokumente
      blindtext
      lipsum
    ]))
  ];
}
