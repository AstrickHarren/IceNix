{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  filterMap = l: builtins.map (x: x.name) (builtins.filter (x: x.enable) l);

  rust = config.icenix.lang.rust;
  rust-bin = pkgs.rust-bin.selectLatestNightlyWith (
    toolchain:
    toolchain.default.override ({
      extensions = filterMap [
        {
          name = "rust-src";
          enable = rust.extensions.rust-src.enable;
        }
        {
          name = "miri";
          enable = rust.extensions.miri.enable;
        }
      ];
      targets = filterMap [
        {
          name = "riscv32imc-unknown-none-elf";
          enable = rust.target.risc.enable;
        }
        {
          name = "wasm32-unknown-unknown";
          enable = rust.target.musl.enable;
        }
        {
          name = "x86_64-unknown-linux-musl";
          enable = rust.target.musl.enable;
        }
      ];
    })
  );
in
{
  options = {
    icenix.lang.rust.mold.enable = lib.mkEnableOption "mold linker";
    icenix.lang.rust.nextest.enable = lib.mkEnableOption "mold linker";

    icenix.lang.rust.extensions.rust-src.enable = lib.mkEnableOption "rust src";
    icenix.lang.rust.extensions.miri.enable = lib.mkEnableOption "rust miri";
    icenix.lang.rust.target.risc.enable = lib.mkEnableOption "risc target";
    icenix.lang.rust.target.musl.enable = lib.mkEnableOption "musl target";
  };
  config = {
    nixpkgs.overlays = [
      inputs.rust-overlay.overlays.default
    ];
    home.packages = [
      rust-bin
      pkgs.clang # rust uses either gcc or clang linker
      pkgs.cargo-expand
      pkgs.cargo-sort
      (lib.mkIf rust.mold.enable pkgs.mold)
      (lib.mkIf rust.nextest.enable pkgs.cargo-nextest)
      (pkgs.wasm-bindgen-cli)
      (lib.mkIf rust.target.risc.enable pkgs.espflash)
      (lib.mkIf rust.target.risc.enable pkgs.cargo-espflash)
      pkgs.cargo-sort
      pkgs.cargo-binstall
    ];
    home.file."${config.home.homeDirectory}/.cargo/config.toml" = {
      text = ''
                [target.x86_64-unknown-linux-gnu]
        	  linker = "clang"
                  rustflags = ["-C", "link-arg=-fuse-ld=${pkgs.mold}/bin/mold"]
      '';
      enable = rust.mold.enable;
    };

    programs.nixvim.plugins.lsp.servers.rust_analyzer = {
      enable = true;
      installCargo = false;
      installRustc = false;
      settings.check.allTargets = true;
      settings.cargo.allFeatures = true;
    };

    programs.nixvim.plugins.autoclose.keys = {
      "'" = {
        disabled_filetypes = [ "rust" ];
      };
    };
  };
}
