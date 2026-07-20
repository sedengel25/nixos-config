# home-manager: sebi's user-level apps and dotfiles.
{ pkgs, ... }:

let
  # Gemeinsame R-Paketliste. Wird von RStudio (IDE) UND der Terminal-R
  # geteilt, damit beide exakt denselben Satz Pakete sehen. Neue Pakete
  # NUR hier eintragen (kein install.packages() zur Laufzeit), dann rebuild –
  # so haben alle Maschinen dieselbe Umgebung. Paketnamen: Punkt -> Unterstrich
  # (data.table -> data_table).
  rEnvPackages = with pkgs.rPackages; [
    languageserver   # R Language Server (Autocomplete/Diagnostics)
    tidyverse
    here
    sf
    data_table
    plotly           # Interaktive Plots (zieht htmlwidgets als Dependency)
  ];
in
{
  home.username = "sebi";
  home.homeDirectory = "/home/sebi";

  # --- Programme mit eigener HM-Integration ---
  programs.firefox.enable = true;

  # Vim: Config als editierbare Datei unter dotfiles/, Plugins deklarativ.
  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile ../dotfiles/vim/vimrc;
    # plugins = with pkgs.vimPlugins; [ vim-ai ];  # später bei Bedarf
  };

  # --- Git ---
  programs.git = {
    enable = true;
    userName = "sedengel";
    userEmail = "sbstdngl@yahoo.com";
    extraConfig.init.defaultBranch = "main";
  };

  # --- Bash ---
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color=auto";
    };
    # Prompt wie auf Arch gewohnt.
    initExtra = ''
      PS1='[\u@\h \W]\$ '
    '';
  };

  # ~/.local/bin auf den PATH (ersetzt das manuelle `export PATH` aus .bashrc).
  home.sessionPath = [ "$HOME/.local/bin" ];

  # SSH-Agent als User-Service. Ersetzt die Arch-spezifische
  # `SSH_AUTH_SOCK=.../gcr/ssh`-Zeile und setzt SSH_AUTH_SOCK selbst.
  services.ssh-agent.enable = true;

  # --- SSH client (TU Dresden HPC Login-Nodes) ---
  programs.ssh = {
    enable = true;
    matchBlocks."?.alpha ?.barnard ?.romeo ?.capella" = {
      hostname = "login%h.hpc.tu-dresden.de";
      user = "sede829c";
      forwardAgent = true;
    };
  };

  # --- Weitere User-Apps ---
  home.packages = with pkgs; [
    alacritty     # Terminal
    rofi          # Launcher
    evolutionWithPlugins  # Mail + EWS-Backend (TU Dresden). Getrennte
                          # evolution/evolution-ews-Pakete verdrahten die
                          # Modul-Discovery in e-d-s nicht -> EWS fehlt im
                          # Server-Typ-Dropdown. Der Wrapper bündelt beides.
    nautilus      # Dateimanager
    dbeaver-bin   # Datenbank-GUI
    claude-code   # Anthropic CLI Coding-Agent (unfree)

    # --- RStudio mit R-Paketen (Data-Science IDE) ---
    # rstudioWrapper bündelt R + die Pakete aus rEnvPackages fest ein; die
    # IDE findet R ohne Discovery-Umwege (anders als Positron auf NixOS).
    (rstudioWrapper.override { packages = rEnvPackages; })

    # --- R fürs Terminal (`R` / `Rscript` auf dem PATH) ---
    # Gleiche Paketliste wie RStudio, damit CLR-Skripte dieselbe Umgebung haben.
    (rWrapper.override { packages = rEnvPackages; })

    # --- Python mit Paketen (globales User-Toolchain) ---
    # python3.withPackages gibt `python3`/`python` auf dem PATH mit genau
    # diesen Bibliotheken. Neue Bibliotheken hier eintragen, dann rebuild.
    (python3.withPackages (ps: with ps; [
      numpy
      pandas
      matplotlib
      scikit-learn
    ]))

    kdePackages.okular  # PDF-Viewer (KDE)
    libreoffice         # Office-Suite
    zotero              # Literaturverwaltung
    zoom-us             # Videokonferenzen (unfree, Attribut heißt zoom-us)
    kdePackages.kate    # Texteditor (KDE)

    # TOTP-Generator: `2fa <service>` liest den Base32-Seed aus
    # ~/.2fa_secrets (Zeilen "service=SEED"), erzeugt den 6-stelligen Code,
    # kopiert ihn in die Zwischenablage und gibt ihn aus. Der Seed selbst
    # ist ein Secret und liegt NICHT im Repo.
    (writeShellApplication {
      name = "2fa";
      runtimeInputs = [ oath-toolkit gawk xclip ];
      text = ''
        SERVICE="''${1:-}"
        if [ -z "$SERVICE" ]; then
          echo "Usage: 2fa <service>"
          exit 2
        fi
        SECRET="$(awk -F= -v s="$SERVICE" '$1==s {print $2; exit}' "$HOME/.2fa_secrets" 2>/dev/null || true)"
        if [ -z "$SECRET" ]; then
          echo "Service nicht gefunden: $SERVICE"
          exit 1
        fi
        CODE="$(oathtool --totp -b "$SECRET")"
        printf '%s' "$CODE" | xclip -selection clipboard
        echo "$CODE (in Zwischenablage kopiert)"
      '';
    })
  ];

  # --- Dotfiles ---
  # i3-Config bleibt vorerst eine einfache Datei, per HM verlinkt nach
  # ~/.config/i3/config. Später kann sie voll deklarativ werden (xsession.windowManager.i3).
  xdg.configFile."i3/config".source = ../dotfiles/i3/config;
  xdg.configFile."alacritty/alacritty.toml".source = ../dotfiles/alacritty/alacritty.toml;

  # RStudio-Preferences deklarativ. editor_keybindings = "vim" schaltet den
  # Vim-Modus im Code-Editor ein (Enum: default|vim|emacs|sublime). Die Datei
  # ist ab jetzt ein Read-only-Symlink in den Store; Pref-Aenderungen also hier
  # im Repo machen + rebuild, nicht mehr ueber die RStudio-GUI persistierbar.
  xdg.configFile."rstudio/rstudio-prefs.json".source = ../dotfiles/rstudio/rstudio-prefs.json;

  # --- Nicht ändern nach Erstinstallation ---
  home.stateVersion = "26.05";
}
