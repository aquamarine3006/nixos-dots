{ pkgs, ... }:
{
  # nbfc-linux for HP Victus fan control
  environment.systemPackages = [ pkgs.nbfc-linux ];

  # nbfc service (runs as root to write to EC)
  systemd.services.nbfc_service = {
    description = "NoteBook FanControl Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.nbfc-linux}/bin/nbfc_service";
      Restart = "on-failure";
    };
  };

  # Allow aqua to run nbfc without sudo password
  security.sudo.extraRules = [{
    users = [ "aqua" ];
    commands = [{
      command = "${pkgs.nbfc-linux}/bin/nbfc";
      options = [ "NOPASSWD" ];
    }];
  }];
}
