# eduVPN client — connects to institutional VPNs via NetworkManager.
#
# Provides `eduvpn-gui` and `eduvpn-cli`. On a fresh machine, launch the GUI
# once and re-add your institution; the client generates its own state/keys
# under ~/.config/eduvpn (do NOT copy those from another machine — they are
# per-machine secrets and are intentionally not tracked in this repo).
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.eduvpn-client ];

  # eduVPN drives NetworkManager to bring up the tunnel. WireGuard is handled
  # natively by NetworkManager; add the OpenVPN plugin for servers that use it.
  # (networking.networkmanager.enable itself lives in modules/common.nix.)
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
}
