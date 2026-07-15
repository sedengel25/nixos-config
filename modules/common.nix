# Baseline every host imports: nix settings, network, locale, ssh, base CLI.
{ pkgs, ... }:

{
  # --- Enable flakes + the new nix CLI ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- Netzwerk ---
  networking.networkmanager.enable = true;

  # --- Zeitzone & Locale ---
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";

  # --- SSH (praktisch fürs Rüberschieben von Configs) ---
  services.openssh.enable = true;

  # --- Basiswerkzeuge auf jedem Host ---
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];
}
