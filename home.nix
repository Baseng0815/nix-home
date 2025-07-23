{ lib, pkgs, ... }:

{
  imports = [
    ./hyprland.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    packages = with pkgs; [
      hello
      zsh-vi-mode
      brave
      discord
      hardinfo2
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

          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh	
        '';
      };

    neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        extraLuaConfig = ''
          local function map(mode, key, action, expr)
            vim.api.nvim_set_keymap(mode, key, action, {
              noremap = true,
              silent = false,
              expr = expr
            })
          end

          map("i", "jk", "<Esc>", false)
          vim.opt.hidden          = true
          vim.opt.wildmenu        = true
          vim.opt.showcmd         = true
          vim.opt.ignorecase      = true
          vim.opt.smartcase       = true
          vim.opt.autoindent      = true
          vim.opt.incsearch       = true
          vim.opt.ruler           = true
          vim.opt.confirm         = true
          vim.opt.visualbell      = true
          vim.opt.number          = true
          vim.opt.relativenumber  = true
          vim.opt.expandtab       = true
          vim.opt.undofile        = true
          vim.opt.ttimeout        = true
          -- I'd like this to be turned on, but it creates lag in .tex files
          vim.opt.cursorline      = false
          vim.opt.cursorcolumn    = false
          vim.opt.langremap       = false
          vim.opt.backup          = false
          vim.opt.writebackup     = false
          vim.opt.timeout         = false
          vim.opt.wrap            = false
          vim.opt.hlsearch        = false
          vim.opt.startofline     = false

          vim.opt.foldmethod      = "indent"
          vim.opt.foldlevel       = 99
          vim.opt.cinoptions      = {'(0'}
          vim.opt.cmdheight       = 2
          vim.opt.laststatus      = 2
          vim.opt.conceallevel    = 0
          vim.opt.encoding        = "utf-8"
          vim.opt.backspace       = {"indent", "eol", "start"}
          vim.opt.cmdheight       = 2
          vim.opt.updatetime      = 300
          vim.opt.shortmess       = vim.opt.shortmess + "c"
          vim.opt.signcolumn      = "yes"
          vim.opt.ttimeoutlen     = 200
          vim.opt.shiftwidth      = 2
          vim.opt.softtabstop     = 2
          vim.opt.colorcolumn     = "81"

          vim.opt.completeopt     = {"menu", "menuone", "noselect"}

          -- remove swap and backup files from working directory
          -- vim.opt.undodir         = "/home/bastian/.vim/.undo"
          -- vim.opt.backupdir       = "/home/bastian/.vim/.backup"
          -- vim.opt.directory       = "/home/bastian/.vim/.swp"

          vim.g.indentLine_setConceal = 0
          vim.cmd("syntax on")
          -- vim.cmd("colorscheme gruvbox")
          vim.cmd("filetype plugin indent on")
          vim.cmd("hi Normal ctermbg=NONE guibg=NONE")
          vim.cmd("set scrolloff=9999")
        '';
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
