{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
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
    ipxe,
    pipxe,
    ...
  }: (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };

    in {
      defaultPackage = import ./package.nix {
        inherit pkgs netboot_xyz pciids ipxe pipxe;
      };
    })
  );
}
