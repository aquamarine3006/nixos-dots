{ pkgs, inputs, ... }:
let
  pantheon-sddm = pkgs.stdenvNoCC.mkDerivation {
    name = "pantheon-sddm";
    src  = inputs.pantheon-sddm;
    installPhase = ''
      mkdir -p $out/share/sddm/themes/PantheonSDDM
      cp -r . $out/share/sddm/themes/PantheonSDDM
    '';
  };
in
{
  services.displayManager.sddm = {
    enable         = true;
    wayland.enable = true;
    theme          = "PantheonSDDM";
    package        = pkgs.kdePackages.sddm;
    extraPackages  = with pkgs; [
      kdePackages.qtwayland
      kdePackages.qtsvg
      kdePackages.qtmultimedia
      kdePackages.qqc2-breeze-style
      bibata-cursors
    ];
  };

  environment.etc."sddm.conf.d/theme.conf".text = ''
    [Theme]
    Current=PantheonSDDM
    ThemeDir=${pantheon-sddm}/share/sddm/themes
    CursorTheme=Bibata-Modern-Classic
  '';

  environment.systemPackages = [ pantheon-sddm pkgs.bibata-cursors ];
}
