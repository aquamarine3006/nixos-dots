{ ... }:
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd         = "qs ipc call lock lock";
        before_sleep_cmd = "qs ipc call lock lock";
        after_sleep_cmd  = "hyprctl dispatch dpms on";
      };
      listener = [
        { timeout = 300; on-timeout = "brightnessctl -s set 10%"; on-resume = "brightnessctl -r"; }
        { timeout = 600; on-timeout = "qs ipc call lock lock"; }
        { timeout = 660; on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on"; }
      ];
    };
  };
}
