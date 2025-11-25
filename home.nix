{ lib, pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./neovim.nix
    ./stylix.nix
  ];

  nixpkgs.config.allowUnfree = true;
  fonts.fontconfig = {
    enable = lib.mkForce true;
    defaultFonts = {
      serif = [ "DejaVu Serif" "Noto Serif CJK JP" ];
      sansSerif = [ "DejaVu Sans" "Noto Sans CJK JP" ];
      monospace = [ "Source Code Pro" "Noto Sans Mono CJK JP" ];
    };
  };

  home = {
    packages = with pkgs; [
      # gui
      jetbrains-toolbox
      brave
      hardinfo2
      zotero
      libreoffice
      spotify
      pavucontrol
      ansel

      # tui or gui-from-terminal
      pinentry-curses # password entry for gpg-agent
      zsh-fzf-tab
      zsh-fzf-history-search
      zsh-vi-mode
      sxiv
      zathura
      mpv
      killall
      jupyter
      rustup # we still use shell.nix like a good nix user, this is just for LSP
      ffmpeg
      vulkan-tools
      zip
      unzip

      # other utility
      nil # Nix language server
      wl-clipboard-rs
      texlive.combined.scheme-full
      nfs-utils

      # fonts
      source-code-pro
      ipafont
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      nerd-fonts.symbols-only
      nerd-fonts.fira-code
    ];

    username = "bastian";
    homeDirectory = "/home/bastian";
    stateVersion = "25.05";

    sessionVariables = {
      INPUT_METHOD  = "fcitx";
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE  = "fcitx";
      XMODIFIERS    = "@im=fcitx";
      XIM_SERVERS   = "fcitx";
    };
  };


  services = {
    dunst = {
      enable = true;
    }; 

    flameshot = {
      enable = true;
      package = pkgs.flameshot.override { enableWlrSupport = true; };
    };

    easyeffects = {
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

        alias lg=lazygit
        alias v=nvim

        bindkey -M viins '^R' fzf-history-widget
        bindkey -M vicmd '^R' fzf-history-widget
        bindkey '^@' autosuggest-accept
      '';
    };

    ripgrep-all = {
      enable = true;
    };

    ripgrep = {
      enable = true;
    };

    yt-dlp = {
      enable = true;
    };

    hyprlock = {
      enable = true;
    };

    vscode = {
      enable = true;
    };

    uv = {
      enable = true;
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

    git = {
      enable = true;
      userEmail = "bastian.engel00@gmail.com";
      userName = "Bastian Engel";
      signing = {
        key = "42E899B7DC869CD8";
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
          size = "64px";
        };
      };
    };

    spotify-player = {
      enable = true;
    };
  };
  
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-configtool
      ];
      waylandFrontend = true;
      settings = {
        inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "jp";
            DefaultIM = "mozc";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "mozc";
        };
        globalOptions = {
          Hotkey = {
            NextInputMethod = "Super+space";
            TriggerInputMethod = "";
          };
        };
      };
    };
  };
}
