{ config, lib, pkgs, ... }:

let
  # Two files home-manager deliberately does NOT own, sourced at the very end of
  # hyprland.conf so they win over everything defined in Nix. This is what makes
  # display changes possible without a rebuild:
  #
  #   monitors.conf  written by nwg-displays (its default output path). Do not
  #                  hand-edit: saving from the GUI rewrites the whole file.
  #   local.conf     hand-written per-location overrides that nwg-displays does
  #                  not know about, e.g. hyprsplit's monitor_priority.
  #
  # Both are seeded empty on activation if absent, since Hyprland throws a config
  # error for a `source` pointing at a missing file.
  monitorsConf = "${config.xdg.configHome}/hypr/monitors.conf";
  localConf = "${config.xdg.configHome}/hypr/local.conf";

  # Mirror the focused monitor onto every other output, for presentations where
  # the projector should show what the laptop panel shows. Runtime-only: `off`
  # just reloads the config, which re-applies hyprland.conf + monitors.conf.
  hypr-mirror = pkgs.writeShellApplication {
    name = "hypr-mirror";
    runtimeInputs = [
      pkgs.jq
      config.wayland.windowManager.hyprland.finalPackage
    ];
    text = ''
      mode="''${1:-toggle}"
      if [ "$mode" = toggle ]; then
        if [ "$(hyprctl -j monitors | jq '[.[] | select(.mirrorOf != "none")] | length')" -gt 0 ]; then
          mode=off
        else
          mode=on
        fi
      fi

      case "$mode" in
        off)
          # A reload keeps plugins loaded, so hyprsplit survives this.
          hyprctl reload
          ;;
        on)
          src=$(hyprctl -j activeworkspace | jq -r '.monitor')
          hyprctl -j monitors \
            | jq -r --arg src "$src" '.[] | select(.name != $src) | .name' \
            | while read -r mon; do
                hyprctl keyword monitor "$mon,preferred,auto,1,mirror,$src"
              done
          ;;
        *)
          echo "usage: hypr-mirror [on|off|toggle]" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  home.packages = [
    pkgs.nwg-displays # GTK monitor layout editor, writes ${monitorsConf}
    hypr-mirror
  ];

  home.activation.hyprMutableConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for f in ${monitorsConf} ${localConf}; do
      if [ ! -e "$f" ]; then
        run mkdir -p $VERBOSE_ARG "$(dirname "$f")"
        run touch "$f"
      fi
    done
  '';

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

    # Sourced from extraConfig rather than settings.source, because
    # sourceFirst = true would otherwise hoist these to the top of the file,
    # where the Nix-defined rules below would override them instead of the
    # other way round. extraConfig is always appended last.
    extraConfig = ''
      source = ${monitorsConf}
      source = ${localConf}
    '';

    # https://wiki.hypr.land/Configuring/Variables/
    settings = {
      "$mod" = "ALT";

      # Catch-all fallback: any output without a rule of its own comes up at its
      # preferred mode, placed automatically to the right. This alone makes a
      # projector or a strange conference-room screen work on hotplug with no
      # config at all. Named defaults per machine live in
      # device-specific/*/home.nix; both are overridden by ${monitorsConf}.
      monitor = [ ",preferred,auto,1" ];

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
        "META,d,exec,nwg-displays"
        "META,p,exec,hypr-mirror"
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
