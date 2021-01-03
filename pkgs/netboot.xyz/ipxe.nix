{
  pkgs,
  ipxe,
  ...
}:

let
  bootloaders = [
  ];

  mkDrv = {
    platform,
    targets,
    thispkgs,
    extraOptions ? [],
  }: with thispkgs; stdenv.mkDerivation {
    pname = "ipxe-${platform}";
    version = ipxe.rev;

    src = ipxe;

    nativeBuildInputs = [
      perl
      cdrkit
      openssl
      gnu-efi
      mtools
      dosfstools
    ];

    NIX_CFLAGS_COMPILE = "-Wno-error";

    makeFlags = [
      "ECHO_E_BIN_ECHO=echo"
      "ECHO_E_BIN_ECHO_E=echo"
    ];

    buildFlags = targets;

    hardeningDisable = [ "pic" "stackprotector" ];
  };

  aarch64 = mkDrv {
    platform = "aarch64";
    targets = [ "bin-arm64-efi/snp.efi" ];
    thispkgs = pkgs.crossPkgs "aarch64-linux";
  };

  x86-bios = stdenv.mkDerivation {
    platform = "x86-bios";

    targets = [
      "bin/ipxe.dsk"
      "bin/ipxe.usb"
      "bin/ipxe.iso"
      "bin/ipxe.lkrn"
      "bin/undionly.kpxe"
    ];

    extraOptions = [
      "IMAGE_COMBOOT"
    ];

    thispkgs = pkgs;
  };

  x86-efi = stdenv.mkDerivation {
    platform = "x86-efi";

    targets = [
      "bin-x86_64-efi/ipxe.efi";
      "bin-x86_64-efi/ipxe.efirom";
      "bin-x86_64-efi/ipxe.usb";
    ];

    thispkgs = pkgs;
  };

in pkgs.symlinkJoin {
  name = "ipxe-${ipxe.rev}";

  paths = [
    aarch64
    x86-bios
    x86-efi
  ];
}
