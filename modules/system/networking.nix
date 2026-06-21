{ lib, ... }:
{
  networking.networkmanager.enable = lib.mkForce true;
  networking.wireless.enable       = lib.mkForce false;  # NM handles wifi; prevents option conflict

  networking.firewall = {
    enable          = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };
}
