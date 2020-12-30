{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  description = "";

  outputs = { self, nixpkgs, flake-utils }: (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };

    in with pkgs.lib; {
      lib = {
        tryCallPackage = path: overrides: if pathExists path then callPackage path overrides else null;
        orDefault = arg: default: if arg != null then arg else default;
      };
    })
  );
}
