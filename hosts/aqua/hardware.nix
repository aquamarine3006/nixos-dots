{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules           = [ ];
  boot.kernelModules                  = [ "kvm-amd" ];
  boot.extraModulePackages            = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/25be3bf5-da5c-407b-b285-17d96dec1906";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device  = "/dev/disk/by-uuid/F3B1-2E01";
    fsType  = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/ed3ec70c-6ca1-4d85-bc48-a9d0666f2434"; }
  ];

  nixpkgs.hostPlatform             = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
