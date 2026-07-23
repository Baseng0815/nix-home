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
      serif = [
        "DejaVu Serif"
        "Noto Serif CJK JP"
      ];
      sansSerif = [
        "DejaVu Sans"
        "Noto Sans CJK JP"
      ];
      monospace = [
        "Source Code Pro"
        "Noto Sans Mono CJK JP"
      ];
    };
  };

  home = {
    packages = with pkgs; [
      # gui
      jetbrains-toolbox
      firefox
      hardinfo2
      zotero
      libreoffice
      spotify
      pavucontrol
      ansel
      steam
      xfce.thunar
      xfce.tumbler
      gimp2
      nautilus
      beekeeper-studio # sql client
      qpwgraph # pipewire patchbay

      # tui or gui-from-terminal
      pinentry-curses # password entry for gpg-agent
      zsh-fzf-tab
      zsh-fzf-history-search
      zsh-vi-mode
      nsxiv
      zathura
      mpv
      killall
      jupyter
      ffmpeg
      vulkan-tools
      zip
      unzip
      wireguard-tools
      brightnessctl

      # network debugging
      traceroute
      mtr # traceroute + ping in one
      dnsutils # dig, nslookup
      # wireshark comes from programs.wireshark in the system config
      # (needs the setcap dumpcap wrapper for non-root capture)
      tcpdump
      nmap # port scanner, also provides ncat
      netcat-openbsd
      socat
      iperf3 # throughput testing
      ethtool
      whois
      ipcalc
      iftop # bandwidth per connection
      nethogs # bandwidth per process
      arp-scan
      ngrep
      lsof
      speedtest-cli

      # other utility
      nodejs
      nil # Nix language server
      texlab # LaTeX language server
      wl-clipboard-rs
      texlive.combined.scheme-full
      nfs-utils
      man-pages
      man-pages-posix
      sshfs
      # zsh-powerlevel10k

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
      DIRENV_LOG_FORMAT = "";
      INPUT_METHOD = "fcitx";
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      XIM_SERVERS = "fcitx";
    };
  };

  services = {
    dunst = {
      enable = true;
    };

    mpris-proxy = {
      enable = true;
    };

    flameshot = {
      enable = true;
      package = pkgs.flameshot.override { enableWlrSupport = true; };

      settings.General = {
        useGrimAdapter = true;
      };
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
      pinentry.package = pkgs.pinentry-qt;
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
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ~/.p10k.zsh

        alias la=lazygit
        alias v=nvim

        bindkey -M viins '^R' fzf-history-widget
        bindkey -M vicmd '^R' fzf-history-widget
        bindkey '^@' autosuggest-accept
      '';
    };

    obs-studio = {
      enable = true;
    };

    hyprshot = {
      enable = true;
    };

    ssh = {
      enable = true;
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          identityFile = "~/.ssh/id_ed25519.github.com";
          addKeysToAgent = "yes";
        };
        "gitlab.cc-asp.fraunhofer.de" = {
          hostname = "gitlab.cc-asp.fraunhofer.de";
          identityFile = "~/.ssh/id_ed25519.gitlab.cc-asp.fraunhofer.de";
          addKeysToAgent = "yes";
        };
        "ki1-vm" = {
          hostname = "ki1-vm";
          identityFile = "~/.ssh/id_ed25519.ki1-vm";
          addKeysToAgent = "yes";
          user = "bas39150";
        };
      };
    };

    nnn = {
      enable = true;
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

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    vesktop = {
      enable = true;
    };

    claude-code = {
      enable = true;
    };

    git = {
      enable = true;
      settings = {
        user = {
          email = "bastian.engel00@gmail.com";
          name = "Bastian Engel";
        };
      };
      signing = {
        key = "0xCADCBA90F60269CF";
        signByDefault = true;
      };
    };

    lazygit = {
      enable = true;
    };

    alacritty = {
      enable = true;
      settings = {
        scrolling.history = 100000;
        keyboard.bindings = [
          {
            key = "J";
            mods = "Control|Shift";
            action = "ScrollPageDown";
          }
          {
            key = "K";
            mods = "Control|Shift";
            action = "ScrollPageUp";
          }
          {
            key = "N";
            mods = "Control|Shift";
            action = "SpawnNewInstance";
          }
        ];
      };
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

    java = {
      enable = true;
      package = pkgs.jdk25_headless;
    };
  };

  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "image/png" = [ "nsxiv.desktop" ];
        "image/jpg" = [ "nsxiv.desktop" ];
        "image/jpeg" = [ "nsxiv.desktop" ];
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
        "video/mp4" = [ "mpv.desktop" ];
        "video/mpeg" = [ "mpv.desktop" ];
        "video/webm" = [ "mpv.desktop" ];
      };
    };
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-gtk
        fcitx5-mozc
        qt6Packages.fcitx5-configtool
      ];
      waylandFrontend = true;
      settings = {
        inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "keyboard-de";
          "Groups/0/Items/2".Name = "mozc";
        };
        globalOptions = {
          Hotkey = {
            # Alt+` must be a strict on/off toggle (MS-IME style), never an
            # enumeration through the whole group on repeated presses.
            EnumerateWithTriggerKeys = false;
            EnumerateSkipFirst = false;
          };
          # MS-IME-style Alt+`: toggle between direct (keyboard-us, the
          # group's first entry) and the last active IME (mozc) — i.e.
          # romaji/alphanumeric vs. kana input.
          "Hotkey/TriggerKeys"."0" = "Alt+grave";
          # Meta+Space cycles English -> German -> Japanese.
          "Hotkey/EnumerateForwardKeys"."0" = "Super+space";
        };
      };
    };
  };
}
