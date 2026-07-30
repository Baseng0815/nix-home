{ lib, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
    };

    settings = {
      mainBar = {
        layer = "top";
        position = "top";

        modules-center = [ "clock" ];

        clock = {
          interval = 1;
          format = "{:%F %T (%a, Week %U)}";
        };

        modules-left = [ "hyprland/workspaces" ];

        "hyprland/workspaces" = {
          # One bar per monitor, each showing only its own monitor's tags.
          all-outputs = false;

          # hyprsplit gives the Nth monitor the global workspace ids
          # N*9+1 .. N*9+9. Relabel them back to 1-9 so every bar shows
          # dwm-style tag numbers rather than 10-18, 19-27, ...
          format = "{icon}";
          format-icons = builtins.listToAttrs (
            builtins.concatMap (
              mon:
              builtins.genList (i: {
                name = toString (mon * 9 + i + 1);
                value = toString (i + 1);
              }) 9
            ) (lib.range 0 3)
          );
        };

        modules-right = [ "cpu" "battery" "memory" "disk" "network" "privacy" "wireplumber" ];

        cpu = {
          interval = 5;
          format = "󰻠 {usage}% ({avg_frequency}GHz)";
          on-click = "exec alacritty -e sh -c \"htop\"";
        };

        temperature = {
          hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
        };

        battery = {
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          format = "{icon} {capacity}%";
        };

        memory = {
          interval = 5;
          format = " {used}GiB/{total}GiB ({percentage}%)";
        };

        disk = {
          interval = 30;
          format = " {used}/{total} ({percentage_used}%)";
          path = "/";
        };

        network = {
          format = "󰲊 {ipaddr}/{cidr} on {ifname}";
          format-ethernet = "󰈁 {ipaddr}/{cidr} on {ifname}";
          format-wifi = "󰖩 {ipaddr}/{cidr} on {ifname}";
        };

        wireplumber = {
          format-icons = [ "" "󰕿" "󰖀" "󰕾" ];
          format = "{icon} {volume}%";
        };
      };
    };

    style = ''
      * {
        font-family: Symbols Nerd Font, FontAwesome, sans-serif;
        font-size: 14px;
      }

      window#waybar {
        background-color: rgba(0, 0, 0, 0);
        color: #FFFFFF;
      }

      #cpu,
      #temperature,
      #memory,
      #battery,
      #disk,
      #network,
      #privacy,
      #wireplumber,
      #workspaces,
      #clock {
        background-color: rgba(1.0, 1.0, 1.0, 0.5);
        padding: 0px 5px;
        border-radius: 5px;
        border: 2px solid #8C98BD;
        margin-right: 0.5em;
        margin-left: 0.5em;
      }

      #workspaces button {
        color: #FFFFFF;
      }

      #workspaces button:hover {
        color: #030303;
      }
    '';
  };
}
