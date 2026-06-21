{
  description = "aqua's nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pantheon-sddm = {
      url = "github:OminduD/PantheonSDDM";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, pantheon-sddm, ... }@inputs:
  {
    nixosConfigurations.aqua = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/aqua/default.nix ];
    };
  };
}
