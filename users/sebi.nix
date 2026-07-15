# System-level account for sebi. Per-user app config lives in ../home/sebi.nix.
{ pkgs, ... }:

{
  users.users.sebi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.bash;
  };
}
