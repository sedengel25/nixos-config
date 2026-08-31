{
  description = "sebi's NixOS configuration (multi-host)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

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
        desktop = mkHost { host = "desktop"; };
        server  = mkHost { host = "server"; home = ./home/server.nix; };
      };
    };
}
