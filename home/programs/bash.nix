{ ... }:
{
  programs.bash = {
    enable           = true;
    enableCompletion = true;

    shellAliases = {
      nrs  = "sudo nixos-rebuild switch --flake ~/nixos-dots#aqua";
      nrb  = "sudo nixos-rebuild boot   --flake ~/nixos-dots#aqua";
      nrd  = "sudo nixos-rebuild dry-build --flake ~/nixos-dots#aqua";
      up   = "nix flake update ~/nixos && nrs";
      ls   = "eza --icons=always";
      ll   = "eza -la --icons=always --git";
      lt   = "eza --tree --icons=always -L 2";
      cat  = "bat --style=plain";
      grep = "rg";
      hme  = "nvim ~/nixos-dots/home/default.nix";
      hypc = "nvim ~/nixos-dots/home/dotfiles/hyprland/hyprland.conf";
      qsc  = "nvim ~/nixos-dots/home/dotfiles/quickshell/";
      net  = "kitty --class impala -e impala";
    };

    initExtra = ''
      eval "$(zoxide init bash)"
    '';
  };

  programs.starship = {
    enable                = true;
    enableBashIntegration = true;
    settings = {
      format = "$directory$git_branch$git_status$character";
      character.success_symbol = "[❯](bold purple)";
      character.error_symbol   = "[❯](bold red)";
      directory.style          = "bold cyan";
      git_branch.style         = "bold pink";
    };
  };
}
