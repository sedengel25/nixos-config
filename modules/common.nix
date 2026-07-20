# Baseline every host imports: nix settings, network, locale, ssh, base CLI.
{ pkgs, ... }:

{
  # --- Enable flakes + the new nix CLI ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- Unfreie Pakete erlauben (claude-code, positron, NVIDIA-Treiber …) ---
  # Gilt via home-manager.useGlobalPkgs auch für home.packages.
  nixpkgs.config.allowUnfree = true;

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

    # Schnelle Such-Tools. Achtung: das Binary von `fd` heisst `fd`
    # (nicht `fdfind` wie auf Debian/Ubuntu); ripgrep liefert `rg`.
    fd        # schneller find-Ersatz
    ripgrep   # schneller grep-Ersatz (rg)

    # Archive: packen/entpacken
    zip
    unzip
    p7zip   # 7z / 7za
  ];
}
