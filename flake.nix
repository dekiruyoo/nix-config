{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    #prismlauncher-cracked.url = "github:Diegiwg/PrismLauncher-Cracked";
  };

  outputs = { 
    self, 
    nixpkgs, 
    nix-flatpak, 
    home-manager,
    sops-nix,
    #prismlauncher-cracked
  }: {
    #packages.x86_64-linux.default = prismlauncher-cracked.packages.x86_64-linux.default;
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager

	./configuration.nix
        sops-nix.nixosModules.sops
      ];
    };

    
    
  };
}
