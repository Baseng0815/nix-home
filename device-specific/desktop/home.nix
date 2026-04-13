
{ lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.extraConfig = ''
    monitor=DP-5,2560x1440@165,0x0,1
    monitor=DP-4,1920x1080@144,2560x0,1
  '';

  programs.waybar.settings.mainBar.output = [ "DP-5" "DP-4" ];
}
