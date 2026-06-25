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
      theme = "cuts";
      themePackages = with pkgs; [
		(adi1090x-plymouth-themes.override {
				selected_themes = [ "cuts" ];
		}) ];
    };
  };
}
