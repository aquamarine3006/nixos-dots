{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/system/boot.nix
    ../../modules/system/sddm.nix
  ];

  networking.hostName = "aqua";

  users.users.aqua = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.bash;
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
}
