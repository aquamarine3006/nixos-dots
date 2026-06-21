{ pkgs, ... }:
{
  gtk = {
    enable = true;
    theme.package = pkgs.adw-gtk3;
    theme.name    = "adw-gtk3-dark";
    iconTheme.package = pkgs.papirus-icon-theme;
    iconTheme.name    = "Papirus-Dark";
    cursorTheme.package = pkgs.bibata-cursors;
    cursorTheme.name    = "Bibata-Modern-Classic";
    cursorTheme.size    = 24;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt.enable             = true;
  qt.platformTheme.name = "gtk3";
  qt.style.name         = "adwaita-dark";

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme    = "adw-gtk3-dark";
    icon-theme   = "Papirus-Dark";
    cursor-theme = "Bibata-Modern-Classic";
    cursor-size  = 24;
    font-name    = "Inter 11";
  };
}
