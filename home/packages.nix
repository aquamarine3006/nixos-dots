{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    inputs.quickshell.packages.${pkgs.system}.default
    eza bat ripgrep fd zoxide fzf jq
    btop fastfetch gdu neovim lazygit
    mpv amberol
    firefox
    matugen awww
    wl-clipboard cliphist wl-clip-persist
    hyprpicker grim slurp satty
    impala
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    inter noto-fonts noto-fonts-color-emoji
    dconf-editor adw-gtk3 gnome-tweaks glib
    papirus-icon-theme bibata-cursors
    libnotify
    file-roller p7zip unzip zip
    gnome-keyring seahorse
    vim
    cava
  ];
}
