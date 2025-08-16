{ lib, pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./neovim.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    packages = with pkgs; [
      hello
      zsh-vi-mode
      brave
      hardinfo2
      zotero
    ];

    username = "bastian";
    homeDirectory = "/home/bastian";
    stateVersion = "25.05";
  };

  services = {
    dunst = {
      enable = true;
    }; 
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      initContent = ''
        function zvm_config() {
          ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
        }

        setopt AUTO_CD
        bindkey '^@' autosuggest-accept

        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh	
      '';
    };

    vesktop = {
      enable = true;
    };

    waybar = {
      enable = true;
      systemd = {
        enable = true;
      };

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          output = [ "DP-1" "DP-3" ];

          modules-center = [ "clock" ];

          clock = {
            interval = 1;
            format = "{:%F %T (%a, Week %U)}";
          };

          modules-left = [ "hyprland/workspaces" ];

          "hyprland/workspaces" = {

          };

          modules-right = [ "cpu" "temperature" "memory" "disk" "network" "privacy" "pulseaudio" ];

          cpu = {
            interval = 5;
            format = "CPU: {usage}% ({avg_frequency}GHz)";
            on-click = "exec alacritty -e sh -c \"htop\"";
          };

          temperature = {
            hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
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
        #disk,
        #network,
        #privacy,
        #pulseaudio,
        #workspaces,
        #clock {
          background-color: rgba(1.0, 1.0, 1.0, 0.5);
          padding: 5px;
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

    git = {
      enable = true;
      userEmail = "bastian.engel00@gmail.com";
      userName = "Bastian Engel";
    };

    lazygit = {
      enable = true;
    };

    alacritty = {
      enable = true;
    };

    rofi = {
      enable = true;
    };

    spotify-player = {
      enable = true;
    };
  };
}
