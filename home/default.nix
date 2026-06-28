{ config, inputs, pkgs, ... }:
let
  repo = "${config.home.homeDirectory}/nixos-dots";
  dots = "${repo}/home/dotfiles";
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [
    ./packages.nix
    ./programs/zsh.nix
    ./programs/git.nix
    ./programs/kitty.nix
    ./programs/theming.nix
    ./programs/idle.nix
  ];
  home = {
    username      = "aqua";
    homeDirectory = "/home/aqua";
    stateVersion  = "26.05";
  };
  programs.home-manager.enable = true;
  xdg.configFile = {
    "quickshell".source = link "${dots}/quickshell";
    "matugen".source    = link "${dots}/matugen";
    "kitty/colors.conf".source = link "${dots}/kitty/colors.conf";
    "hypr/hyprland.conf".source    = link "${dots}/hyprland/hyprland.conf";
    "hypr/animations.conf".source  = link "${dots}/hyprland/animations.conf";
    "hypr/keybinds.conf".source    = link "${dots}/hyprland/keybinds.conf";
    "hypr/windowrules.conf".source = link "${dots}/hyprland/windowrules.conf";
    "hypr/colors.conf".source      = link "${dots}/hyprland/colors.conf";
  };
  home.file."scripts" = {
    source    = link "${dots}/scripts";
    recursive = true;
  };
  home.sessionPath = [ "${config.home.homeDirectory}/scripts" ];
}
