{ ... }:

{
  services.syncthing = {
    enable = true;
    user = "sebi";
    group = "users";
    dataDir = "/home/sebi";
    configDir = "/home/sebi/.config/syncthing";
  };
}
