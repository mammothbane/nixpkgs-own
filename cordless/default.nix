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

buildGo113Module rec {
  pname = "cordless";
  version = "0.0.2-nosemver";

  src = sources.cordless;

  goPackagePath = "github.com/Bios-Marcel/cordless";
  modSha256 = "1zfk7m3376gldi0apvzjvi07321d45hcvr1xmz5jrdrfq5hfhkf2";
  subpackages = ["."];

  meta = with lib; {
    description = "command-line discord client";
    homepage = https://github.com/Bios-Marcel/cordless;
    license = licenses.bsd3;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
