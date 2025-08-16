{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    image = pkgs.fetchurl {
      url = "https://gruvbox-wallpapers.pages.dev/wallpapers/anime/anime_skull.png";
      hash = "sha256-cI8tgi0ADVpvWbk+8tTKA+4RmV1pdLNLfCdc5EUxQj4=";
    };
  };
}
