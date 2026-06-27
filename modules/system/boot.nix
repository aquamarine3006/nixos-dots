{ pkgs, lib, ... }:
let
  grubphemous = pkgs.stdenv.mkDerivation {
    pname = "grubphemous";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "pvtoari";
      repo = "grubphemous-theme";
      rev = "master";
      hash = "sha256-9BPKNL7k2nePB1GvJ3MS/BqgcYddbY+Rw3vlxdjGyn0=";
      # run: nix-prefetch-url --unpack https://github.com/pvtoari/grubphemous-theme/archive/main.tar.gz
    };
    installPhase = ''
      mkdir -p $out/grubphemous
      cp -r grubphemous/* $out/grubphemous/
    '';
  };
in
{
  boot = {
    # remove systemd-boot
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        theme = "${grubphemous}/grubphemous";
        useOSProber = false;
        configurationLimit = 10;
        timeout = 180;
      };
    };

    kernelPackages = pkgs.linuxPackages_latest;
    initrd.kernelModules = [ "amdgpu" ];
    initrd.systemd.enable = true;
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
        })
      ];
    };
  };
}
