{ lib, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    # dwm-style per-monitor workspaces. Each monitor owns its own set of 9,
    # so ALT+1..9 always acts on the focused monitor instead of dragging a
    # global workspace across screens.
    #
    # NOTE: home-manager loads plugins with `exec-once = hyprctl plugin load`,
    # i.e. after the config is parsed and only at session start. A bare
    # `hyprctl reload` does NOT re-load the plugin, so after switching you
    # need either a fresh session or a manual `hyprctl plugin load`.
    plugins = [ pkgs.hyprlandPlugins.hyprsplit ];

    # https://wiki.hypr.land/Configuring/Variables/
    settings = {
      "$mod" = "ALT";

      # Monitor -> workspace-set assignment lives in device-specific/*/home.nix,
      # since it has to name actual outputs.
      plugin.hyprsplit = {
        num_workspaces = 9;

        # Off, so empty tags don't exist and therefore don't show up in waybar
        # (dwm only draws tags that have clients or are selected). The tag ->
        # monitor binding does not depend on this: hyprsplit's dispatchers always
        # create workspaces on the focused monitor, and ensureGoodWorkspaces()
        # re-homes stragglers on every config reload / monitor hotplug
        # regardless of this flag. All it controls is pre-creating and pinning
        # all 9 per monitor.
        persistent_workspaces = false;
      };

      general = {
        layout = "master";
        gaps_in = 0;
        gaps_out = 0;
      };

      cursor = {
        inactive_timeout = 3;
      };
        

      # https://wiki.hypr.land/Configuring/Animations/
      animations = {
        enabled = false;
      };

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindc = [
        "$mod, mouse:272, togglefloating"
      ];

      # https://wiki.hypr.land/Configuring/Binds/
      bind = [
        "$mod,Print,exec,hyprshot --mode region --clipboard-only"
        "$mod SHIFT,Print,exec,hyprshot --mode region"
        "$mod SHIFT,RETURN,exec,alacritty"
        "$mod,p,exec,rofi -show drun -display-drun \"\""
        "META,l,exec,hyprlock"
        "META SHIFT,l,exec,systemctl suspend && hyprlock"
        "META,e,exec,thunar"
        "$mod,w,killactive"
        "$mod SHIFT,w,forcekillactive"
        "$mod,Space,togglefloating"
        "$mod,b,exec,pkill -SIGUSR1 waybar"
        "$mod,m,fullscreen"
        "$mod,O,fullscreen"

        # dwm focusmon / tagmon. The trailing `silent` is what makes tagmon
        # behave like dwm's: without it Hyprland calls rawMonitorFocus +
        # changeWorkspace + warpCursor, dragging your focus and cursor to the
        # other monitor along with the window.
        "$mod,comma,focusmonitor,-1"
        "$mod,period,focusmonitor,+1"
        "$mod SHIFT,comma,movewindow,mon:-1 silent"
        "$mod SHIFT,period,movewindow,mon:+1 silent"

        # Reclaim windows stranded on the workspaces of an unplugged monitor.
        "$mod,g,split:grabroguewindows"

        "$mod,Tab,workspace,previous"
        # ...silent, so this doesn't follow the window either.
        "$mod SHIFT,Tab,movetoworkspacesilent,previous"

        # https://wiki.hypr.land/Configuring/Master-Layout/
        "$mod,j,layoutmsg,cyclenext"
        "$mod,k,layoutmsg,cycleprev"
        "$mod,i,layoutmsg,addmaster"
        "$mod,d,layoutmsg,removemaster"
        "$mod,h,layoutmsg,mfact -0.05"
        "$mod,l,layoutmsg,mfact +0.05"
        "$mod,Return,layoutmsg,swapwithmaster master"
        "$mod SHIFT,up,layoutmsg,orientationtop"
        "$mod SHIFT,right,layoutmsg,orientationright"
        "$mod SHIFT,left,layoutmsg,orientationleft"
        "$mod SHIFT,down,layoutmsg,orientationbottom"
        "$mod,c,layoutmsg,orientationcenter"
      ]
      # dwm tags: $mod+N views tag N on the focused monitor, $mod+SHIFT+N sends
      # the focused window to tag N without following it.
      ++ builtins.concatMap (i: [
        "$mod,${toString i},split:workspace,${toString i}"
        "$mod SHIFT,${toString i},split:movetoworkspacesilent,${toString i}"
      ]) (lib.range 1 9);

      input = {
        kb_options = "ctrl:nocaps";
        repeat_rate = 100;
        repeat_delay = 200;
      };
    };
  };
}
