# System-Teil des Monitoring-Workspaces (i3 $ws7 "Monitoring").
#
# Hier steht NUR, was zwingend NixOS-Ebene braucht: die beiden Tools, die ohne
# Extra-Capabilities nichts sehen. Die TUIs selbst (btop, nvtop, s-tui) und der
# Launcher liegen im home-manager-Profil (home/sebi.nix), weil sie reine
# User-Programme sind.
#
# Warum ueberhaupt Wrapper: iotop liest Taskstats per Netlink und bandwhich
# schnueffelt am Socket -- beides darf ein normaler User nicht. Ohne die
# Wrapper laufen sie nur unter sudo, und ein sudo-Passwortprompt in einem
# Dashboard-Pane ist unbrauchbar.
{ pkgs, ... }:

{
  # --- Per-Prozess Disk-I/O ---
  # Legt /run/wrappers/bin/iotop mit cap_net_admin+p an. `package` auf iotop-c
  # (C-Rewrite) statt des Python-Originals: startet schneller und hat die
  # kompaktere Anzeige, die in einem schmalen Grid-Pane noch lesbar ist.
  programs.iotop = {
    enable = true;
    package = pkgs.iotop-c;
  };

  # --- Per-Prozess Netzwerk-Bandbreite ---
  # Setzt das Paket in systemPackages UND legt den setcap-Wrapper an.
  # Hinweis: `programs.nethogs` gibt es in nixpkgs 26.05 NICHT -- deshalb
  # bandwhich als Tool der Wahl fuer "welcher Prozess zieht die Leitung voll".
  programs.bandwhich.enable = true;

  # --- Sensoren ---
  environment.systemPackages = with pkgs; [
    lm_sensors  # liefert `sensors` + `sensors-detect`; Datenquelle fuer s-tui
  ];
}
