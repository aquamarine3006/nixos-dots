{ pkgs, inputs, lib, ... }:

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
      # Use the sleek, built-in Breeze theme (no massive downloads required)
      themePackages = [ pkgs.kdePackages.breeze-plymouth ];
      theme = "breeze";
    };
  };
}
