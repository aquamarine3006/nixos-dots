{ lib, ... }:
{
  networking.networkmanager.enable = lib.mkForce true;
  # networking.wireless.enable       = lib.mkForce false;  # NM handles wifi; prevents option conflict
  networking.networkmanager.wifi.backend = "wpa_supplicant";
  networking.wireless.iwd.enable = false;

  networking.firewall = {
    enable          = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };
}
