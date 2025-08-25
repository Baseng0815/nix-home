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
        output = [ "eDP-1" ];

        modules-center = [ "clock" ];

        clock = {
          interval = 1;
          format = "{:%F %T (%a, Week %U)}";
        };

        modules-left = [ "hyprland/workspaces" ];

        "hyprland/workspaces" = {

        };

        modules-right = [ "cpu" "battery" "memory" "disk" "network" "privacy" "pulseaudio" ];

        cpu = {
          interval = 5;
          format = "CPU: {usage}% ({avg_frequency}GHz)";
          on-click = "exec alacritty -e sh -c \"htop\"";
        };

        temperature = {
          hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
        };

        battery = {
          format = "Battery: {capacity}%";
        };

        memory = {
          interval = 5;
          format = "Memory: {used}GiB/{total}GiB ({percentage}%)";
        };

        disk = {
          interval = 30;
          format = "Disk: {used}/{total} ({percentage_used}%)";
          path = "/";
        };

        network = {
          format = "{ipaddr}/{cidr} on {ifname}";
        };

        pulseaudio = {

        };
      };
    };

    style = ''
      * {
        font-family: FontAwesome, Roboto, Helvetica, Arial, sans-serif;
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
      #pulseaudio,
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
