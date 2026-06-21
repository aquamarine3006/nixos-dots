{ pkgs, inputs, lib, ... }:

let
  # Package the hexagon theme from adi1090x's repo
  hexagon-plymouth = pkgs.stdenvNoCC.mkDerivation {
    name = "hexagon-plymouth";
    src = inputs.plymouth-themes;
    
    dontBuild = true;
    
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/plymouth/themes/hexagon
      # The repo stores files under hexagon_1/hexagon/
      cp -r hexagon_1/hexagon/* $out/share/plymouth/themes/hexagon/
      
      # Fix the .plymouth config file to point to the Nix store
      substituteInPlace $out/share/plymouth/themes/hexagon/hexagon.plymouth \
        --replace "/usr/share/plymouth/themes/hexagon" "$out/share/plymouth/themes/hexagon"
      runHook postInstall
    '';
  };
in
{
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;

    # CRITICAL FOR AMD: Enable early modesetting so Plymouth can draw immediately
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
      themePackages = [ hexagon-plymouth ];
      theme = "hexagon";
    };
  };
}
