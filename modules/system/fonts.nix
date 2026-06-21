{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      inter
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono" ];
        sansSerif = [ "Inter" "Noto Sans" ];
        serif     = [ "Noto Serif" ];
        emoji     = [ "Noto Color Emoji" ];
      };
    };
  };
}
