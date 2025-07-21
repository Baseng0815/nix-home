{ lib, pkgs, ... }

{
  home = {
    packages = with pkgs; [
      hello
    ];

    username = "bastian";
    homeDirectory = "/home/bastian";
    stateVersion = "25.05";
  };
}
