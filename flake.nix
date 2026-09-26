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
        overlays = [
          # TEMPORARY: claude-code 2.1.257, not yet in nixos-unstable.
          # Files vendored from nixpkgs pkgs/by-name/cl/claude-code; drop this
          # overlay and ./pkgs/claude-code once the bump lands upstream.
          (final: prev: {
            claude-code = prev.callPackage ./pkgs/claude-code/package.nix { };
          })
          # codegraph is not in nixpkgs at all; upstream ships prebuilt
          # release bundles, which ./pkgs/codegraph patches for NixOS.
          (final: prev: {
            codegraph = prev.callPackage ./pkgs/codegraph/package.nix { };
          })
        ];
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
