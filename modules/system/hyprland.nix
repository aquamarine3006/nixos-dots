{ inputs, pkgs, ... }:
{
  imports = [ inputs.hyprland.nixosModules.default ];

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    # WLR_NO_HARDWARE_CURSORS removed because AMD doesn't need it, and it broke SDDM!
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    cliphist
    grim
    slurp
    satty
    swww
    hyprpicker
    libnotify
    brightnessctl
    playerctl
    pamixer
    hypridle
    networkmanagerapplet
    blueman
    impala
    hyprsunset       # Night light tool for Wayland
  ];
}
