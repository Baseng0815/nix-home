
{ lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.extraConfig = ''
    monitor=DP-5,2560x1440@165,0x0,1
    monitor=DP-4,1920x1080@144,2560x0,1
  '';

  # hyprsplit reserves workspace sets in this order, so the primary 1440p panel
  # gets tags 1-9 and the secondary gets 10-18 (relabelled 1-9 in waybar).
  # Without this it falls back to monitor id order, which hands 1-9 to DP-4.
  wayland.windowManager.hyprland.settings.plugin.hyprsplit.monitor_priority = "DP-5, DP-4";

  programs.waybar.settings.mainBar.output = [ "DP-5" "DP-4" ];
}
