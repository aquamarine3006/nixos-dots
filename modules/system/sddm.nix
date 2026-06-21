{ pkgs, ... }:

let
  # 1. Get the source code of sddm-astronaut from nixpkgs
  sddm-astronaut-src = pkgs.sddm-astronaut.src;

  # 2. Create a customized version of the theme using YOUR wallpaper
  custom-astronaut = pkgs.stdenvNoCC.mkDerivation {
    name = "sddm-astronaut-custom";
    src = sddm-astronaut-src;
    
    dontBuild = true;
    
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/sddm/themes/sddm-astronaut-theme
      cp -r . $out/share/sddm/themes/sddm-astronaut-theme/
      
      # Overwrite the default background with your countryside/anime wallpaper
      cp ${../assets/wallpaper.jpg} $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/default.jpg
      runHook postInstall
    '';
  };
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    
    # SDDM needs these Qt6 libraries to render the QML theme
    extraPackages = with pkgs; [
      kdePackages.qtwayland
      kdePackages.qtsvg
      kdePackages.qtmultimedia
      kdePackages.qqc2-breeze-style
      kdePackages.qtdeclarative
      kdePackages.qt5compat
    ];
  };

  environment.systemPackages = [ 
    custom-astronaut 
    pkgs.bibata-cursors 
  ];

  environment.etc."sddm.conf.d/cursor.conf".text = ''
    [Theme]
    CursorTheme=Bibata-Modern-Classic
  '';
}
