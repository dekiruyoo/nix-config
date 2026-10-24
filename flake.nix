{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    durdraw.url = "github:durdraw/durdraw";

    # Helix related. Gosh, this looks so ugly.
    helix-config = {
      url = "github:mattwparas/helix-config";
      flake = false;
    };
    hxwiki = {
      url = "github:sipmann/hxwiki";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      #nixpkgs-unstable,
      nix-flatpak,
      home-manager,
      sops-nix,
      durdraw,
      ...
    }@inputs:
    {
      hxwiki = {
        url = "github:sipmann/hxwiki";
        flake = false;
      };

      nixosConfigurations = {
        t1me = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs durdraw; };
          modules = [
            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops

            ./configuration.nix
            ./hosts/t1me.nix
            ./hardware-configuration.nix
            ./ly.nix
          ];
        };

        # Insert future host here.
      };
    };
}
