{
  description = "NixOS home manager configuration";

  inputs = {
    nixpkgs ={
      url = "nixpkgs/nixos-25.05";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, stylix, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      homeConfigurations = {
	bastian = home-manager.lib.homeManagerConfiguration {
	  inherit pkgs;
	  modules = [
            stylix.homeModules.stylix
            ./home.nix
          ];
	};
      };
    };
}
