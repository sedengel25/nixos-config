# System-level account for sebi. Per-user app config lives in ../home/sebi.nix.
{ pkgs, ... }:

{
  users.users.sebi = {
    isNormalUser = true; # creates the user
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ]; # grants privileges (wheel grants sudo)
    shell = pkgs.bash; # what the user gets dropped into after logging in
  };
}
