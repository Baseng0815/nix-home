{
  description = "NixOS home manager configuration";

  inputs = {
    nixpkgs ={
      url = "nixpkgs/nixos-25.11";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.11";
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
          ./device-specific/desktop/hardware.nix
          ./device-specific/desktop/configuration.nix
        ];
      };

      homeConfigurations.bastian = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          stylix.homeModules.stylix
          ./home.nix
          ./device-specific/desktop/home.nix
        ];
      };
    };
}
