let
  sources = import nix/sources.nix;
  overlay = _: pkgs: {
    niv = import sources.niv {};
  };
  pkgs = import sources.nixpkgs {
    overlays = [ overlay ];
    config = {};
  };
in

with pkgs;

buildGoModule rec {
  pname = "cordless";
  version = "0.0.1-nosemver";

  src = sources.cordless;

  goPackagePath = "github.com/Bios-Marcel/cordless";
  modSha256 = "1yi9n6kj77lz8hp27g4kr1aax24dwjkn5sq2pylql4mdmh34gidr";
  subpackages = ["."];

  meta = with lib; {
    description = "command-line discord client";
    homepage = https://github.com/Bios-Marcel/cordless;
    license = licenses.bsd3;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
