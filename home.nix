{ lib, pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./waybar.nix
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
      jupyter
      rustup # we still use shell.nix like a good nix user, this is just for LSP

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

    yt-dlp = {
      enable = true;
    };

    hyprlock = {
      enable = true;
    };

    texlive = {
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
}
