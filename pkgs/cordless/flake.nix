{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";

    cordless = {
      url = "github:Bios-Marcel/cordless";
      flake = false;
    };
  };

  description = "command-line discord client";

  outputs = { self, nixpkgs, flake-utils, cordless }: (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };

      pkg = with pkgs; buildGoModule {
        pname = "cordless";
        version = "0.0.2-${cordless.rev}";

        src = cordless;

        vendorSha256 = "01anbhwgwam70dymcmvkia1xpw48658rq7wv4m7fiavxvnli6z2y";
        subpackages = ["."];

        meta = with lib; {
          description = "command-line discord client";
          homepage = https://github.com/Bios-Marcel/cordless;
          license = licenses.bsd3;
          platforms = platforms.linux ++ platforms.darwin;
        };
      };

    in {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          go
        ];
      };

      defaultPackage = pkg;

      defaultApp = {
        type = "app";
        program = "${pkg}/bin/cordless";
      };
    })
  );
}
