{ ... }:
{
  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMono Nerd Font";
    font.size = 13;
    settings = {
      window_padding_width     = 12;
      confirm_os_window_close  = 0;
      background_opacity       = "0.92";
      dynamic_background_color = true;
      cursor_shape              = "beam";
      tab_bar_style             = "powerline";
      scrollback_lines          = 10000;
      enable_audio_bell         = false;
    };
    extraConfig = ''
      include colors.conf
    '';
  };
}
