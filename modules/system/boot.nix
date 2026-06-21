{ pkgs, inputs, ... }:
let
  proxzima = pkgs.stdenvNoCC.mkDerivation {
    name = "proxzima-plymouth";
    src  = inputs.proxzima-plymouth;
    installPhase = ''
      mkdir -p $out/share/plymouth/themes/proxzima
      cp -r proxzima/. $out/share/plymouth/themes/proxzima/
      sed -i "s|/usr|$out|g" \
        $out/share/plymouth/themes/proxzima/*.plymouth 2>/dev/null || true
    '';
  };
in
{
  boot = {
    loader.systemd-boot.enable      = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages                  = pkgs.linuxPackages_latest;

    plymouth = {
      enable        = true;
      themePackages = [ proxzima ];
      theme         = "proxzima";
    };

    consoleLogLevel = 0;
    initrd.verbose  = false;
    kernelParams    = [
      "quiet"
      "splash"
      "udev.log_level=0"
      "rd.udev.log_level=0"
    ];
  };
}
