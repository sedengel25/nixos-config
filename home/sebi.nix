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
  ];

  # --- Dotfiles ---
  # i3-Config bleibt vorerst eine einfache Datei, per HM verlinkt nach
  # ~/.config/i3/config. Später kann sie voll deklarativ werden (xsession.windowManager.i3).
  xdg.configFile."i3/config".source = ../dotfiles/i3/config;
  xdg.configFile."alacritty/alacritty.toml".source = ../dotfiles/alacritty/alacritty.toml;

  # --- Nicht ändern nach Erstinstallation ---
  home.stateVersion = "26.05";
}
