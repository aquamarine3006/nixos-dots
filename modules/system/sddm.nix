{ pkgs, ... }:

let 
  base = pkgs.sddm-astronaut.override {
    themeConfig = {
      Background = "Backgrounds/wall.jpg";
   };
};
  sddm-astronaut = pkgs.runCommand "sddm-astronaut-custom" {} ''
	cp -r $(base)/. $out
	chmod -R u+w $out
	cp ${./wall.jpg} $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/wall.jpg
'';
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
      kdePackages.qtwayland
      kdePackages.qtsvg
      kdePackages.qtmultimedia
      kdePackages.qqc2-breeze-style
      kdePackages.qtdeclarative
      kdePackages.qt5compat
      bibata-cursors
      sddm-astronaut
    ];
  };

  environment.systemPackages = [ 
    sddm-astronaut
    pkgs.bibata-cursors 
  ];

  environment.pathsToLink = [ "/share/icons" ];

  environment.etc."sddm.conf.d/cursor.conf".text = ''
    [Theme]
    CursorTheme=Bibata-Modern-Classic
    CursorSize=24
  '';

}
