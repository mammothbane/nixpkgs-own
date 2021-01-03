{
  pkgs,
  ipxe,
  opts,
  ...
}:

let
  cacert = builtins.fetchurl {
    url = https://ca.ipxe.org/ca.crt;
    sha256 = "15kwz3liwbdpi8s3v3axaswmp1b3wm3zqps50gmrsiyj4v34fx8d";
  };

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
      cdrkit
      mtools
      dosfstools
      perl
      openssl
    ];

    buildInputs = [
      openssl
      gnu-efi
      lzma
    ];

    doCheck = stdenv.hostPlatform == stdenv.buildPlatform;

    NIX_CFLAGS_COMPILE = "-Wno-error";
    makeFlags = [
      "ECHO_E_BIN_ECHO=echo"
      "ECHO_E_BIN_ECHO_E=echo"
      "EMBED=${import ./embed.nix opts}"
    ];
    buildFlags = targets;
    hardeningDisable = [ "pic" "stackprotector" ];
    enableParallelBuilding = true;

    inherit extraOptions;

    configurePhase = ''
      runHook preConfigure

      mkdir -p src/config/local
      ls src/config/local

      cp ${./config.h} src/config/local/general.h
      chmod u+w src/config/local/general.h

      for opt in $extraOptions; do
        echo "#define $opt" >> src/config/local/general.h
      done

      substituteInPlace src/Makefile.housekeeping --replace '/bin/echo' echo

      runHook postConfigure
    '';

    preBuild = "cd src";

    installPhase = ''
      mkdir -p $out/share/ipxe/${platform}
    '' +
    lib.concatStringsSep "\n" (builtins.map (target: "cp ${target} $out/share/ipxe/${platform}") targets);
  };

  aarch64 = mkDrv {
    platform = "aarch64";
    targets = [ "bin-arm64-efi/snp.efi" ];

    thispkgs = pkgs.reimport {
      crossSystem = "aarch64-linux";
    };
  };

  x86-bios = mkDrv {
    platform = "x86-bios";

    targets = [
      "bin/ipxe.dsk"
      "bin/ipxe.usb"
      "bin/ipxe.iso"
      "bin/ipxe.lkrn"
      "bin/undionly.kpxe"
    ];

    extraOptions = [ "IMAGE_COMBOOT" ];

    thispkgs = pkgs;
  };

  x86-efi = mkDrv {
    platform = "x86-efi";

    targets = [
      "bin-x86_64-efi/ipxe.efi"
      "bin-x86_64-efi/ipxe.efirom"
      "bin-x86_64-efi/ipxe.usb"
    ];

    thispkgs = pkgs;
  };

in pkgs.symlinkJoin {
  name = "ipxe-${ipxe.rev}";

  paths = [
    # aarch64
    x86-bios
    x86-efi
  ];
}
