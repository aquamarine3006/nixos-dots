{ pkgs, ... }:

{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    
    # SDDM needs these Qt6 libraries to render, and bibata-cursors to show the mouse
    extraPackages = with pkgs; [
      kdePackages.qtwayland
      kdePackages.qtsvg
      kdePackages.qtmultimedia
      kdePackages.qqc2-breeze-style
      kdePackages.qtdeclarative
      kdePackages.qt5compat
      bibata-cursors
    ];
  };

  environment.systemPackages = [ 
    pkgs.sddm-astronaut 
    pkgs.bibata-cursors 
  ];

  environment.etc."sddm.conf.d/cursor.conf".text = ''
    [Theme]
    CursorTheme=Bibata-Modern-Classic
  '';
}
