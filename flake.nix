{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ignis = {
      url = "github:linkfrg/ignis";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ignis-config = {
      url = "github:astrickharren/ignis-config";
      flake = false;
    };
  };

  outputs =
    icenixInputs:
    let
      mkSystem = import ./util/mkSystem.nix;
    in
    {
      mkIcenix =
        {
          inputs,
          settings,
        }:
        mkSystem {
          inherit settings;
          inputs = icenixInputs // inputs;
          homeModules = [
            ./home-manager
            settings.home
            icenixInputs.catppuccin.homeManagerModules.catppuccin
            icenixInputs.nixvim.homeManagerModules.nixvim
            icenixInputs.niri.homeModules.niri
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [
                icenixInputs.nur.overlays.default
                icenixInputs.niri.overlays.niri
              ];
            }
          ];
          nixosModules = [
            ./os/default.nix
            settings.os or { }
            {
              icenix = settings.icenix;
            }
          ];
        };
    };
}
