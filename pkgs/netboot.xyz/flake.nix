{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-20.09";
    flake-utils.url = "github:numtide/flake-utils";

    netboot_xyz = {
      url = "github:netbootxyz/netboot.xyz/2.0.29";
      flake = false;
    };

    pciids = {
      url = "github:netbootxyz/pciids/master";
      flake = false;
    };

    pipxe = {
      url = "github:netbootxyz/pipxe/master";
      flake = false;
    };

    ipxe = {
      url = "github:ipxe/ipxe/master";
      flake = false;
    };
  };

  description = "netboot.xyz";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    netboot_xyz,
    pciids,
    pipxe,
    ...
  } @ inputs: (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;

        overlays = [
          (self: super: {
            reimport = (args: import nixpkgs ({
              inherit system;
            } // args));
          })
        ];
      };

      ipxe = import ./ipxe {
        inherit pkgs;
        inherit (inputs) ipxe;

        opts = {
          site = "nathanperry.dev";
          domain = "boot.nathanperry.dev";
          version = "0.1.0";
        };
      };

      netboot = import ./package.nix {
        inherit (inputs) ipxe;
        inherit pkgs netboot_xyz pciids pipxe;
      };

    in {
      packages = {
        inherit ipxe netboot;
      };

      defaultPackage = netboot;
    })
  );
}
