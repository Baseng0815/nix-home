
{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    piper # GUI for the G502 HERO; talks to services.ratbagd in the system config
  ];

  # Baseline for this machine. Anything saved from nwg-displays into
  # ~/.config/hypr/monitors.conf is sourced afterwards and wins.
  wayland.windowManager.hyprland.settings.monitor = [
    "DP-6,2560x1440@165,0x0,1"
    "DP-5,1920x1080@144,2560x0,1"
  ];

  # hyprsplit reserves workspace sets in this order, so the primary 1440p panel
  # gets tags 1-9 and the secondary gets 10-18 (relabelled 1-9 in waybar).
  # Without this it falls back to monitor id order, which hands 1-9 to DP-4.
  # nwg-displays does not know about this setting; to change it on the fly put
  # a `plugin { hyprsplit { monitor_priority = ... } }` block into
  # ~/.config/hypr/local.conf and run `hyprctl reload`.
  wayland.windowManager.hyprland.settings.plugin.hyprsplit.monitor_priority = "DP-5, DP-4";

  # Deliberately no `output` filter: waybar spawns a bar on every connected
  # output, so a newly plugged screen gets its tags too.
}
