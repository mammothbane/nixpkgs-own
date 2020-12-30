{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";

    tty0tty = {
      url = "github:freemed/tty0tty";
      flake = false;
    };
  };

  description = "null modem emulator";

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs: (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      stdenv = pkgs.stdenv;

      tty0tty = { kernel ? pkgs.linux }: stdenv.mkDerivation {
        pname = "tty0tty";
        version = "0.1.0";

        src = inputs.tty0tty;

        enableParallelBuilding = true;

        buildInputs = [ pkgs.nukeReferences ];

        makeFlags = [
          "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
          "ARCH=${stdenv.hostPlatform.platform.kernelArch}"
        ];

        installPhase = ''
          mkdir -p                $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/tty/serial
          cp module/tty0tty.ko    $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/tty/serial
          nuke-refs $(find $out -name "*.ko")
        '';
      };

    in {
      defaultPackage = tty0tty {};

      nixosModule = { pkgs, lib, config, ... }:
        let kernel = config.boot.kernelPackages.kernel;

        in {
          options.services.tty0tty = {
            enable = lib.mkEnableOption "tty0tty";
          };

          config = lib.mkIf config.services.tty0tty.enable {
            boot = {
              extraModulePackages = [ (tty0tty { inherit kernel; }) ];
              kernelModules = [ "tty0tty" ];
            };

            services.udev.extraRules = ''
              KERNEL=="tnt*" SUBSYSTEM=="tty", MODE="0660", GROUP="uucp"
            '';

            users.groups = {
              uucp.gid = config.ids.gids.uucp;
            };
          };
        };
    })
  );
}
