{ pkgs, inputs, lib, ... }:

let
  proxzima = pkgs.stdenvNoCC.mkDerivation {
    name = "proxzima-plymouth";
    src = inputs.proxzima-plymouth;
    
    dontBuild = true;
    
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/plymouth/themes/proxzima
      cp -r proxzima/* $out/share/plymouth/themes/proxzima/
      
      # Use Nix's native substituteInPlace to guarantee the image paths point to the Nix store
      if [ -f "$out/share/plymouth/themes/proxzima/proxzima.plymouth" ]; then
        substituteInPlace $out/share/plymouth/themes/proxzima/proxzima.plymouth \
          --replace "/usr/share/plymouth/themes/proxzima" "$out/share/plymouth/themes/proxzima"
      fi
      runHook postInstall
    '';
  };
in
{
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;

    # 1. CRITICAL FOR AMD: Enable early modesetting so Plymouth can draw immediately
    initrd.kernelModules = [ "amdgpu" ];
    kernelParams = [
      "quiet"
      "splash"
      "amdgpu.modeset=1"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];

    consoleLogLevel = 0;
    initrd.verbose = false;

    plymouth = {
      enable = true;
      themePackages = [ proxzima ];
      theme = "proxzima";
    };
  };
}
