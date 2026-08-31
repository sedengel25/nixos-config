# home-manager-Profil für headless Hosts (server).
#
# Bewusst eigenständig statt "sebi.nix minus GUI": home/sebi.nix bleibt damit
# unangetastet, und ein Rebuild von x1/desktop kann sich nicht ändern. Preis
# ist etwas Doppelung (vim/git/bash) — wird das mehr, lohnt ein gemeinsames
# home/base.nix, das beide Profile importieren.
{ pkgs, ... }:

{
  home.username = "sebi";
  home.homeDirectory = "/home/sebi";

  # Vim: gleiche Config wie auf den Desktops, aus dotfiles/.
  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile ../dotfiles/vim/vimrc;
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
    initExtra = ''
      PS1='[\u@\h \W]\$ '
    '';
  };

  home.sessionPath = [ "$HOME/.local/bin" ];

  # SSH-Agent als User-Service (praktisch für git push vom Server aus).
  services.ssh-agent.enable = true;

  # Die HPC-matchBlocks aus home/sebi.nix fehlen hier absichtlich — der
  # Server redet nicht mit den TU-Login-Nodes. Bei Bedarf von dort kopieren.

  # --- Terminal-Werkzeuge ---
  home.packages = with pkgs; [
    htop      # Prozess-/Last-Monitor
    tmux      # damit lange Jobs einen SSH-Disconnect überleben
    rsync     # Dateien synchronisieren
    ncdu      # interaktive Plattenplatz-Analyse
  ];

  # --- Nicht ändern nach Erstinstallation ---
  home.stateVersion = "26.05";
}
