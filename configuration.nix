# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  networking.hostName = "enlap"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  programs = {
    zsh.enable = true;
    light.enable = true;

    hyprland = {
      enable = true;
      withUWSM = true;
    };

    tmux = {
      enable = true;
      shortcut = "a";
      historyLimit = 100000;
      keyMode = "vi";
      plugins = with pkgs.tmuxPlugins; [
        yank
        vim-tmux-navigator
        vim-tmux-focus-events
      ];
      extraConfig = ''
        unbind h
        unbind l
        unbind j
        unbind k
        bind h previous-window
        bind l next-window
        bind j split-window -v
        bind k split-window -h
        unbind '"'
        unbind %

        bind r source-file ~/.tmux.conf

        # -r = repeat
        bind -r C-k resize-pane -U
        bind -r C-j resize-pane -D
        bind -r C-h resize-pane -L
        bind -r C-l resize-pane -R

        # Smart pane switching with awareness of Vim splits.
        # See: https://github.com/christoomey/vim-tmux-navigator
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
        # -n = no leader
        bind -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
        bind -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
        bind -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
        bind -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
        tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
        if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
            "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
        if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
            "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

        bind -T copy-mode-vi 'C-h' select-pane -L
        bind -T copy-mode-vi 'C-j' select-pane -D
        bind -T copy-mode-vi 'C-k' select-pane -U
        bind -T copy-mode-vi 'C-l' select-pane -R
        bind -T copy-mode-vi 'C-\' select-pane -l

        bind-key -T copy-mode-vi 'v' send -X begin-selection     # Begin selection in copy mode.
        bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle  # Begin selection in copy mode.
        bind-key -T copy-mode-vi 'y' send -X copy-selection      # Yank selection in copy mode.
      '';
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bastian = {
    isNormalUser = true;
    home = "/home/bastian";
    description = "Bastian Engel";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # only systemwide tools; user applications go into the user config
    home-manager
    git
    gnumake
    neovim   
    vim
    htop
    wget
    acpi
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services = {
    actkbd = {
      enable = true;
      bindings = [
	{ keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 20"; }
	{ keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 20"; }
      ];
    };

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      wireplumber = {
        enable = true;
      };
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
