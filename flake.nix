{
  description = "NixOS home manager configuration";

  inputs = {
    nixpkgs ={
      url = "nixpkgs/nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    minesddm = {
      url = "github:Baseng0815/sddm-theme-minesddm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, stylix, minesddm, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in {
      nixosConfigurations.bastian = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        modules = [
          minesddm.nixosModules.default
          ./device-specific/laptop-01/hardware.nix
          ./device-specific/laptop-01/configuration.nix
        ];
      };

      homeConfigurations.bastian = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          stylix.homeModules.stylix
          ./home.nix
          ./device-specific/laptop-01/home.nix
        ];
      };
    };
}
