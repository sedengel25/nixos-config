# home-manager: sebi's user-level apps and dotfiles.
{ pkgs, ... }:

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
    evolution     # Mail
    nautilus      # Dateimanager
    dbeaver-bin   # Datenbank-GUI
    positron-bin  # Data-Science IDE (Attribut heißt positron-bin)
    claude-code   # Anthropic CLI Coding-Agent (unfree)

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

  # --- Nicht ändern nach Erstinstallation ---
  home.stateVersion = "26.05";
}
