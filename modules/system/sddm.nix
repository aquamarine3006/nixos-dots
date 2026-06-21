{ pkgs, ... }:

{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sugar-dark";
    package = pkgs.kdePackages.sddm;
    
    extraPackages = with pkgs; [
      kdePackages.qtwayland
      kdePackages.qtsvg
      kdePackages.qtmultimedia
      kdePackages.qqc2-breeze-style
      kdePackages.qtdeclarative
      kdePackages.qt5compat
    ];
  };

  environment.systemPackages = with pkgs; [
    sddm-sugar-dark
    bibata-cursors
  ];

  environment.etc."sddm.conf.d/cursor.conf".text = ''
    [Theme]
    CursorTheme=Bibata-Modern-Classic
  '';
}
