{
  description = "aqua's nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pantheon-sddm = {
      url = "github:OminduD/PantheonSDDM";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, quickshell,
               pantheon-sddm, ... }@inputs:
  {
    nixosConfigurations.aqua = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/aqua/default.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.aqua = import ./home/default.nix;
          home-manager.backupFileExtension = "bak";
        }
      ];
    };
  };
}
