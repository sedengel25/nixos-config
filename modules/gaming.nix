# Steam + Gaming-Helfer. Braucht die 32-Bit-GL-Libs aus einem GPU-Modul
# (hier modules/nvidia.nix mit hardware.graphics.enable32Bit).
{ ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;       # Steam Remote Play
    dedicatedServer.openFirewall = true;  # Source-Dedicated-Server
  };

  # `gamemoded` optimiert z.B. CPU-Governor, solange ein Spiel läuft.
  # In Steam als Launch-Option nutzbar: `gamemoderun %command%`.
  programs.gamemode.enable = true;
}
