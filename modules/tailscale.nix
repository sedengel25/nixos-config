{ lib, ... }:

{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = lib.mkDefault "client";
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
