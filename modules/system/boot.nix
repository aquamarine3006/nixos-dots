{ pkgs, lib, ... }:

{
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;

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
      # "glow" is a sophisticated, minimal pulsing animation built into nixpkgs.
      # By using pkgs.plymouth instead of pkgs.nixos-artwork, we avoid the NixOS logo.
      themePackages = [ pkgs.plymouth ];
      theme = "glow";
    };
  };
}
