{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";

    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs-mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };

    naersk.url = "github:nmattia/naersk";

    fishnet = {
      url = "github:niklasf/fishnet";
      flake = false;
    };

    fishnet-assets = {
      url = "github:niklasf/fishnet-assets";
      flake = false;
    };
  };

  description = "run stockfish for lichess";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    fishnet,
    fishnet-assets,
    ...
  } @ inputs: (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;

        overlays = [
          (import inputs.nixpkgs-mozilla)

          (self: super: let
            rust = (super.rustChannelOf {
              channel = "nightly";
              date = "2020-12-01";
              sha256 = "16r5lldank00c2bhnrzr1bxfsbvqxzcap5zmh40ri46x0jfbx8jh";
            }).rust.override {
              extensions = ["rust-src"];
            };
          in {
            cargo = rust;
            rustc = rust;
          })
        ];
      };

      naersk = (inputs.naersk.lib."${system}".override {
        inherit (pkgs) cargo rustc;
      });

      pkg = import ./package.nix {
        inherit pkgs fishnet fishnet-assets naersk;
      };

    in {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          cargo
          rustc
        ];
      };

      defaultPackage = pkg;

      defaultApp = {
        type = "app";
        program = "${pkg}/bin/fishnet";
      };

      nixosModule = (import ./module.nix) pkg;
    })
  );
}
