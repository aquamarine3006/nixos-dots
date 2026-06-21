{
  description = "aqua's nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pantheon-sddm = {
      url = "github:OminduD/PantheonSDDM";
      flake = false;
    };

    # New premium Plymouth theme pack
    plymouth-themes = {
      url = "github:adi1090x/plymouth-themes";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, pantheon-sddm, plymouth-themes, ... }@inputs:
  {
    nixosConfigurations.aqua = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/aqua/default.nix ];
    };
  };
}
