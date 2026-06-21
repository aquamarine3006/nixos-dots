{ pkgs, ... }:
{
  services.gnome.gnome-keyring.enable     = true;
  security.pam.services.sddm.enableGnomeKeyring  = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Required for Quickshell's WlSessionLock PAM auth
  security.pam.services.quickshell = {};

  security.polkit.enable = true;

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy    = [ "graphical-session.target" ];
    wants       = [ "graphical-session.target" ];
    after       = [ "graphical-session.target" ];
    serviceConfig = {
      Type      = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart   = "on-failure";
    };
  };

  environment.systemPackages = with pkgs; [
    gnome-keyring
    libsecret
  ];
}
