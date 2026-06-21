{ pkgs, ... }:
{
  services.gvfs.enable    = true;
  services.tumbler.enable = true;

  programs.nautilus-open-any-terminal = {
    enable   = true;
    terminal = "kitty";
  };

  environment.systemPackages = with pkgs; [
    nautilus
    loupe
    seahorse
  ];
}
