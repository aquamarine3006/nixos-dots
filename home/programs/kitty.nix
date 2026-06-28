{ ... }:
{
  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMono Nerd Font Bold";
    font.size = 19;
    settings = {
      window_padding_width         = 16;
      confirm_os_window_close      = 0;
      background_opacity           = "0.97";
      dynamic_background_color     = true;
      sync_to_monitor              = true;
      repaint_delay                = 8;
      mouse_hide_wait              = 0;
      click_interval               = "0.5";
      cursor_trail                 = 1;
      cursor_trail_decay           = "0.08 0.25";
      cursor_trail_start_threshold = 3;
      cursor_shape                 = "block";
      tab_bar_style                = "powerline";
      scrollback_lines             = 100000;
      enable_audio_bell            = false;
      text_fg_override_threshold   = 4;
    };
    extraConfig = ''
      include /home/aqua/.cache/wallust/kitty-colors.conf
    '';
  };
}

