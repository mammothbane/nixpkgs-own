{
  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/master;
    flake-utils.url = github:numtide/flake-utils;

    grafanix = {
      url = github:stolyaroleh/grafanix;
      flake = false;
    };
  };

  description = "";

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs: (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        currentSystem = system;
      };

      pkg = (import inputs.grafanix {}).grafanix;

    in {
      defaultPackage = pkg;

      defaultApp = {
        type = "app";
        program = "${pkg}/bin/grafanix";
      };
    })
  );
}
