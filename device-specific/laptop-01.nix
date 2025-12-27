{ lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.extraConfig = ''
    monitor=HDMI-A-1,2560x1440@144,auto,1
  '';

  programs.waybar.settings.mainBar.output = [ "HDMI-A-1" ];
}
