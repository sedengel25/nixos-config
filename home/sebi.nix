# home-manager: sebi's user-level apps and dotfiles.
{ pkgs, osConfig, ... }:

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
    patchwork        # ggplot2-Plots nebeneinander/kombinieren
    shiny            # Web-App-Framework für R
    DT
    dbscan
    leaflet
    renv
    reticulate
    # In aktuellem nixpkgs als "broken" markiert; Markierung ist oft veraltet
    # und das Paket baut trotzdem. markUnbroken hebt nur diese eine Markierung auf.
    (leaflet_extras.overrideAttrs (o: { meta = o.meta // { broken = false; }; }))
    future
    future_apply
    duckdb
  ];

  # --- Monitoring-Workspace (i3 $ws7) ---

  # Die TUIs des Dashboards. Wird ZWEIMAL gebraucht: in home.packages, damit
  # die Tools auch normal auf der Shell liegen, und als runtimeInputs des
  # `monitoring`-Launchers, damit der nicht auf ein zufaellig passendes $PATH
  # angewiesen ist.
  #
  # nvtop: bewusst die `full`-Variante. Sie bringt die Backends fuer NVIDIA,
  # AMD und Intel mit, und dieselbe home-config laeuft auf desktop (NVIDIA),
  # l14 (AMD) und x1 (Intel) -- so bleibt der GPU-Pane host-unabhaengig.
  #
  # btop: die schlichte Variante. GPU-Support gibt es in nixpkgs nur als
  # btop-cuda bzw. btop-rocm, also ein ANDERES Derivat je nach Karte. Das
  # vertraegt sich nicht mit einem gemeinsamen home-Profil fuer alle drei
  # Hosts -- und es ist unnoetig, weil nvtop die GPU ohnehin abdeckt.
  #
  # Zur Beruhigung: nvtop-full zieht CUDA nur zur BAUZEIT an (fuer das
  # NVIDIA-Backend). Der Runtime-Closure ist ~55 MiB und enthaelt kein CUDA,
  # die Laptops schleppen also nichts Unnoetiges mit.
  #
  # iotop und bandwhich fehlen hier ABSICHTLICH: die kommen als setcap-Wrapper
  # aus modules/monitoring.nix und werden im Launcher ueber /run/wrappers/bin
  # aufgerufen. Staenden sie hier, wuerden sie den Wrapper im PATH verdecken
  # und liefen wieder nur mit sudo.
  monitoringTools = with pkgs; [
    btop
    nvtopPackages.full
    s-tui
  ];

  # Sensor-Pfad fuer i3status (cpu_temperature). i3status' Default waere
  # thermal_zone0 -- das ist auf dem Desktop aber der WLAN-Chip (iwlwifi), nicht
  # die CPU. i3status erlaubt Globs im `path` und nimmt den ersten Treffer;
  # hwmon* faengt die ueber Reboots nicht stabile hwmon-Nummerierung ab.
  #
  # `osConfig` ist die NixOS-Config des Hosts. Sichtbar, weil home-manager hier
  # als NixOS-Modul laeuft (siehe flake.nix). updateMicrocode wird von
  # nixos-generate-config aus dem erkannten CPU-Hersteller gesetzt und ist
  # damit ein verlaesslicher Indikator.
  cpuTempPath =
    if osConfig.hardware.cpu.amd.updateMicrocode
    then "/sys/bus/pci/drivers/k10temp/*/hwmon/hwmon*/temp1_input"    # Tctl (l14, desktop)
    else "/sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input"; # Package id 0 (x1)
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
    extraConfig = {
      safe.directory = [ "/home/sebi/mnt/horse-home/gnn-tap" ];
      init.defaultBranch = "main";
    };
  };

  # --- Bash ---
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      mount-horse-home = "sshfs 1.barnard:/home/h5/sede829c ~/mnt/horse-home -o reconnect,auto_cache,ServerAliveInterval=15,ServerAliveCountMax=3";
      umount-horse-home = "fusermount -uz ~/mnt/horse-home";
      mount-bda = "sshfs sede829c@dgw.zih.tu-dresden.de:/svm/vs-grp105/bda_store ~/mnt/bda_store -o reconnect,auto_cache,ServerAliveInterval=15,ServerAliveCountMax=3";
      umount-bda = "fusermount -uz ~/mnt/bda_store";
    };
    initExtra = ''
      eval "$(dircolors)"
      export LS_COLORS="$LS_COLORS:mh=00"
    '';
  };

  programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        command_timeout = 2000;
        format = "$username@$hostname $directory$git_branch$git_status\${custom.venv}$character";
        character = {
          success_symbol = "[\\$](bold green)";
          error_symbol = "[\\$](bold red)";
        };
        directory.truncation_length = 1;

        # Aktives venv anzeigen. Starship setzt VIRTUAL_ENV_DISABLE_PROMPT=1,
        # d.h. das `(venv)`-Praefix der activate-Skripte faellt weg. Das
        # `python`-Modul greift nur in Python-Verzeichnissen, deshalb hier ein
        # eigenes Modul, das rein an $VIRTUAL_ENV haengt. Heisst das Verzeichnis
        # `.venv` (uv-Default), wird der Projektname statt ".venv" gezeigt.
        custom.venv = {
          when = ''[ -n "$VIRTUAL_ENV" ]'';
          command = ''n=$(basename "$VIRTUAL_ENV"); [ "$n" = ".venv" ] && n=$(basename "$(dirname "$VIRTUAL_ENV")"); printf %s "$n"'';
          format = "[\\($output\\)]($style) ";
          style = "bold yellow";
        };
      };
    };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;   # or enableZshIntegration = true
  };

  # ~/.local/bin auf den PATH (ersetzt das manuelle `export PATH` aus .bashrc).
  home.sessionPath = [ "$HOME/.local/bin" ];

  # SSH-Agent als User-Service. Ersetzt die Arch-spezifische
  # `SSH_AUTH_SOCK=.../gcr/ssh`-Zeile und setzt SSH_AUTH_SOCK selbst.
  services.ssh-agent.enable = true;

  # --- SSH client (TU Dresden HPC Login-Nodes) ---
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks."?.alpha ?.barnard ?.romeo ?.capella" = {
      hostname = "login%h.hpc.tu-dresden.de";
      user = "sede829c";
      forwardAgent = true;
      serverAliveInterval = 30;
      serverAliveCountMax = 5;
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
    seahorse      # GNOME-Schlüsselbund-GUI (Passwörter/SSH/GPG verwalten)
    dbeaver-bin   # Datenbank-GUI
    duckdb
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

    uv            # Python-Paketmanager für projektlokale venvs (z.B. aequilibrae)

    sshfs         # Remote-Verzeichnisse per SSH mounten (z.B. HPC-Nodes),
                  # nutzt FUSE (fusermount-Wrapper ist auf NixOS by default da)

    kdePackages.okular  # PDF-Viewer (KDE)
    pandoc              # Dokumentkonverter (Markdown/HTML/PDF/DOCX ...)
    libreoffice         # Office-Suite
    zotero              # Literaturverwaltung
    zoom-us             # Videokonferenzen (unfree, Attribut heißt zoom-us)
    kdePackages.kate    # Texteditor (KDE)
    xournalpp           # Hand-signature
    pdfarranger         # PDFs zusammenfügen etc.

    # --- Monitoring-Workspace ---
    # Baut den Workspace als Grid auf, oder wechselt nur hin, wenn es ihn
    # schon gibt. Gebunden an $mod+m in dotfiles/i3/config.
    (writeShellApplication {
      name = "monitoring";
      runtimeInputs = [ i3 jq alacritty ] ++ monitoringTools;
      text = ''
        WS="''${1:-Monitoring}"

        # Schon gebaut? Dann nur hinwechseln, statt die Panes zu verdoppeln.
        if i3-msg -t get_workspaces | jq -e --arg ws "$WS" 'any(.name == $ws)' >/dev/null; then
          i3-msg "workspace $WS"
          exit 0
        fi

        # Erst das Geruest, dann die Fenster: append_layout legt pro Blatt ein
        # Platzhalter-Fenster an, das das passende Terminal spaeter verschluckt.
        # Ohne diesen Umweg wuerden aus den fuenf Terminals wegen des globalen
        # `workspace_layout tabbed` fuenf Tabs statt eines Grids.
        i3-msg "workspace $WS"
        i3-msg "append_layout $HOME/.config/i3/monitoring-layout.json"

        # --class setzt WM_CLASS und entscheidet damit, in welches Pane das
        # Fenster faellt (siehe monitoring-layout.json). --hold laesst das
        # Fenster mitsamt Fehlermeldung stehen, falls ein Tool sofort abbricht.
        #
        # iotop und bandwhich BEWUSST ueber den absoluten Wrapper-Pfad: nur der
        # traegt die Capabilities aus modules/monitoring.nix.
        alacritty --class mon_btop      --hold -e btop &
        alacritty --class mon_nvtop     --hold -e nvtop &
        alacritty --class mon_iotop     --hold -e /run/wrappers/bin/iotop &
        alacritty --class mon_bandwhich --hold -e /run/wrappers/bin/bandwhich &
        alacritty --class mon_sensors   --hold -e s-tui &
      '';
    })

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
  ] ++ monitoringTools;

  # --- Dotfiles ---
  # i3-Config bleibt vorerst eine einfache Datei, per HM verlinkt nach
  # ~/.config/i3/config. Später kann sie voll deklarativ werden (xsession.windowManager.i3).
  xdg.configFile."i3/config".source = ../dotfiles/i3/config;
  xdg.configFile."alacritty/alacritty.toml".source = ../dotfiles/alacritty/alacritty.toml;

  # Grid-Geruest fuer den Monitoring-Workspace (siehe `monitoring` oben).
  xdg.configFile."i3/monitoring-layout.json".source = ../dotfiles/i3/monitoring-layout.json;

  # i3status: nicht .source, sondern .text -- der Sensor-Pfad haengt am Host,
  # deshalb wird @CPU_TEMP_PATH@ beim Bauen ersetzt (s. cpuTempPath oben).
  xdg.configFile."i3status/config".text =
    builtins.replaceStrings [ "@CPU_TEMP_PATH@" ] [ cpuTempPath ]
      (builtins.readFile ../dotfiles/i3status/config);

  # RStudio-Preferences deklarativ. editor_keybindings = "vim" schaltet den
  # Vim-Modus im Code-Editor ein (Enum: default|vim|emacs|sublime). Die Datei
  # ist ab jetzt ein Read-only-Symlink in den Store; Pref-Aenderungen also hier
  # im Repo machen + rebuild, nicht mehr ueber die RStudio-GUI persistierbar.
  # force = true, weil RStudio die Datei zur Laufzeit ueberschreibt. Ohne force
  # bricht die HM-Aktivierung ab ("Existing file ... would be clobbered"). Mit
  # force gewinnt bei jedem Rebuild die Repo-Version.
  xdg.configFile."rstudio/rstudio-prefs.json" = {
    source = ../dotfiles/rstudio/rstudio-prefs.json;
    force = true;
  };

  # --- GNOME-/GTK-Einstellungen via dconf ---
  # Nautilus soll standardmäßig die Listenansicht statt Symbolansicht nutzen.
  # Werte: "icon-view" | "list-view". Wirkt für neue Fenster nach dem Rebuild.
  dconf.settings = {
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };
  };

  # --- Nicht ändern nach Erstinstallation ---
  home.stateVersion = "26.05";
}
