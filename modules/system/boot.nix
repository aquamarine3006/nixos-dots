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
      sed -i 's/left = 71%/left = 51%/g' $out/grubphemous/theme.txt
      sed -i 's/top = 61%/top = 51%/g' $out/grubphemous/theme.txt
      sed -i 's/width = 600/width = 1000/g' $out/grubphemous/theme.txt
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
	gfxmodeEfi = "1920x1080x32";
	extraConfig = ''
	  set gfxpayload=keep
	  terminal_output gfxterm
	'';
      };
    };

     extraModprobeConfig = ''
          options rtw89_8852be disable_he=1
	'';

    kernelPackages = pkgs.linuxPackages_latest;
    initrd.kernelModules = [ "amdgpu" ];
    initrd.systemd.enable = true;
    kernelParams = [
      "quiet"
      "splash"
      "amdgpu.modeset=1"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
      "loglevel=0"
      "vt.global_cursor_default=0"
    ];

    consoleLogLevel = 0;
    initrd.verbose = false;

    plymouth = {
      enable = true;
      theme = "dragon";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "dragon" ];
        })
      ];
    };
  };
}
