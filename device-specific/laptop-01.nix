{ lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.extraConfig = ''
    monitor=DVI-I-1,1920x1080@60,0x0,1
    monitor=DVI-I-2,1920x1080@60,1920x0,1,primary
    monitor=eDP-1,1920x1080@60,3840x0,1
  '';

  programs.waybar.settings.mainBar.output = [ "DVI-I-1" "DVI-I-2" "eDP-1" ];
}
