{ lib, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    plugins = [

    ];
      
    # https://wiki.hypr.land/Configuring/Variables/
    settings = {
      "$mod" = "ALT";

      general = {
        layout = "master";
      };

      # https://wiki.hypr.land/Configuring/Animations/
      animations = {
        enabled = false;
      };

      bindm = [
        "$mod,mouse:272,movewindow"
        "$mod,mouse:273,resizewindow"
      ];

      # https://wiki.hypr.land/Configuring/Binds/
      bind = [
        "$mod SHIFT,RETURN,exec,alacritty"
        "$mod,p,exec,rofi -show run"
        "$mod,w,killactive"
        "$mod SHIFT,w,forcekillactive"
        "$mod,Space,togglefloating"
        "$mod,m,fullscreen"
        "$mod,b,exec,pkill -SIGUSR1 waybar"

        "$mod,PERIOD,focusmonitor,+1"
        "$mod,COMMA,focusmonitor,-1"

        "$mod,0,workspace,0"
        "$mod,1,workspace,1"
        "$mod,2,workspace,2"
        "$mod,3,workspace,3"
        "$mod,4,workspace,4"
        "$mod,5,workspace,5"
        "$mod,6,workspace,6"
        "$mod,7,workspace,7"
        "$mod,8,workspace,8"
        "$mod,9,workspace,9"

        "$mod SHIFT,1,movetoworkspace,1"
        "$mod SHIFT,2,movetoworkspace,2"
        "$mod SHIFT,3,movetoworkspace,3"
        "$mod SHIFT,4,movetoworkspace,4"
        "$mod SHIFT,5,movetoworkspace,5"
        "$mod SHIFT,6,movetoworkspace,6"
        "$mod SHIFT,7,movetoworkspace,7"
        "$mod SHIFT,8,movetoworkspace,8"
        "$mod SHIFT,9,movetoworkspace,9"

        "$mod,Tab,workspace,previous"
        "$mod SHIFT,Tab,movetoworkspace,previous"

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
      ];

      input = {
        kb_options = "ctrl:nocaps";
        repeat_rate = 100;
        repeat_delay = 200;
      };
    };

    extraConfig = ''
      windowrule = opacity 0.95 0.95 0.95, class:Alacritty
      monitor=,highres,auto,1
    '';
  };
}
