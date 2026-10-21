{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "sebi";
    dataDir = "/home/sebi";
    configDir = "/home/sebi/.config/syncthing";
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
