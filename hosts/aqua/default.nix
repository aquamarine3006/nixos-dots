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
  ];
  networking.hostName = "aqua";
  users.users.aqua = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.zsh;
  };
  # required for zsh to be a valid login shell system-wide
  programs.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
}
