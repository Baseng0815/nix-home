{ lib, pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./neovim.nix
    ./stylix.nix
  ];

  nixpkgs.config.allowUnfree = true;
  fonts.fontconfig.enable = lib.mkForce true;

  home = {
    packages = with pkgs; [
      # gui
      jetbrains-toolbox
      brave
      hardinfo2
      zotero
      libreoffice

      # tui or gui-from-terminal
      pinentry-curses # password entry for gpg-agent
      zsh-fzf-tab
      zsh-fzf-history-search
      zsh-vi-mode
      sxiv
      zathura
      mpv
      killall

      # other utility
      nil # Nix language server

      # fonts
      source-code-pro
    ];

    username = "bastian";
    homeDirectory = "/home/bastian";
    stateVersion = "25.05";
  };

  services = {
    dunst = {
      enable = true;
    }; 

    gpg-agent = {
      enable = true;
      defaultCacheTtl = 36000;
      maxCacheTtl = 36000;
      defaultCacheTtlSsh = 36000;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-curses;
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
          ZVM_INIT_MODE=sourcing
        }

        setopt AUTO_CD

        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh	
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

        bindkey -M viins '^R' fzf-history-widget
        bindkey -M vicmd '^R' fzf-history-widget
        bindkey '^@' autosuggest-accept
      '';
    };

    gpg = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
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

    git = {
      enable = true;
      userEmail = "bastian.engel00@gmail.com";
      userName = "Bastian Engel";
      signing = {
        key = "81B31C064DD87927";
        signByDefault = true;
      };
    };

    lazygit = {
      enable = true;
    };

    alacritty = {
      enable = true;
    };

    rofi = {
      enable = true;
      extraConfig = {
        show-icons = true;
      };
      theme = {
        "*" = {
          highlight = "bold italic";
          scrollbar = true;
          font = "Source Code Pro 20";
        };

        "element-icon" = {
          size = "32px";
        };
      };
    };

    spotify-player = {
      enable = true;
    };
  };
}
