{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/master;
    flake-utils.url = github:numtide/flake-utils;

    nix-bisect = {
      url = github:timokau/nix-bisect;
      flake = false;
    };
  };

  description = "";

  outputs = { self, nixpkgs, flake-utils, nix-bisect }: (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      pkg = pkgs.callPackage nix-bisect {};

    in {
      defaultPackage = pkg;

      defaultApp = {
        type = "app";
        program = "${pkg}/bin/nix-bisect";
      };
    })
  );
}
