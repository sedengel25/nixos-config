{
  description = "sebi's NixOS configuration (multi-host)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # Zweite nixpkgs-Quelle, ausschliesslich fuer einzeln zurueckgepinnte Pakete.
    # Aktuell nur quarto: 26.05 liefert quarto 1.9.37, das pandoc 3.8.3 erwartet,
    # aber nur pandoc 3.7.0.2 dazu -> Renderfehler "Unknown option
    # syntax-highlighting". 25.11 hat quarto 1.7.34 mit passendem pandoc.
    # Bewusst OHNE inputs.nixpkgs.follows - es muss ein eigener Baum bleiben.
    nixpkgs-2511.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      # Helper: build a host from ./hosts/<name>, wired up with home-manager.
      #
      # `home` waehlt das home-manager-Profil. Voreinstellung ist das
      # Desktop-Profil mit GUI-Apps; headless Hosts uebergeben stattdessen
      # ./home/server.nix. (Welche SYSTEM-Module ein Host bekommt, steht
      # dagegen in hosts/<name>/default.nix.)
      mkHost = { host, home ? ./home/sebi.nix }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${host}

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.sebi = import home;
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        x1      = mkHost { host = "x1"; };
        l14     = mkHost { host = "l14"; };
        desktop = mkHost { host = "desktop"; };
        server  = mkHost { host = "server"; home = ./home/server.nix; };
      };
    };
}
