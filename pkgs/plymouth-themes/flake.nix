# Note: this flake derives the entries in its outputs.<system>.packages
# from walking the directories in inputs.plymouth-themes and heuristically
# checking whether each dir looks like a theme (as well as explicitly
# blacklisting the /templates/ directory). I wrote it this way because
# it makes things easier if the author decides to modify the repo.
#
# Implementing things this way requires an unsafeDiscardStringContext in
# ./package.nix. This is safe because this is a flake, and hence
# reproducible at a given flake.lock. If, however, the underlying repo
# fundamentally changes its structure, updating the input may lead to
# surprising behavior (e.g. all theme packages vanishing, if ./package.nix
# can't find directories that it thinks are themes anymore).

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";

    plymouth-themes = {
      url = "github:adi1090x/plymouth-themes";
      flake = false;
    };
  };

  description = "plymouth themes";

  outputs = { self, nixpkgs, flake-utils, plymouth-themes }: (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      stdenv = pkgs.stdenv;

      themes = builtins.readDir plymouth-themes;

      mkPackage = { name, path, ... }:
        stdenv.mkDerivation {
          pname = "plymouth-themes-${name}";
          version = plymouth-themes.rev;

          src = plymouth-themes;

          buildPhase = ''
            echo ${name} ${path} ${builtins.toJSON themes}
            ls -al
            exit 1
          '';
        };


      pkg = import ./package.nix {
        inherit plymouth-themes pkgs;
      };

    in {
      packages = pkg;

      defaultPackage = pkgs.symlinkJoin {
        name = "all-themes";
        paths = (builtins.attrValues pkg);
      };
    })
  );
}
