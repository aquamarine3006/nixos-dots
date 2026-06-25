{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/system/boot.nix
    ../../modules/system/networking.nix
    ../../modules/system/locale.nix
    ../../modules/system/audio.nix
    ../../modules/system/fonts.nix
    ../../modules/system/security.nix
    ../../modules/system/nautilus.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/sddm.nix
    ../../modules/system/power.nix
    ../../modules/system/fan.nix
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
