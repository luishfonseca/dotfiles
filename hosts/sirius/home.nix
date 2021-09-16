{ lib, pkgs, config, hostName, user, ... }:

{

  imports = [
    ../../modules/home/miscprogs
    ../../modules/home/rofi
    ../../modules/home/alacritty
    ../../modules/home/neovim
    ../../modules/home/chromium

    ../../modules/home/git
    ../../modules/home/gpg
    ../../modules/home/sxhkd
    ../../modules/home/picom
    ../../modules/home/password_store

    ../../modules/home/userdirs

    ../../modules/home/bspwm
    ../../modules/home/polybar

    ../../modules/home/gruvbox
    ../../modules/home/wallpaper
  ];

  options = with lib; {
    hostName = mkOption { type = types.str; };
    user = mkOption { type = types.str; };
  };
  config = { inherit hostName user; };

  config.home.stateVersion = "21.05";
}
