{
  pkgs,
  fishnet,
  fishnet-assets,
  naersk,
  ...
}:

let
  patched_assets = pkgs.stdenv.mkDerivation {
    pname = "patched-${fishnet-assets.rev}";
    version = fishnet-assets.rev;

    src = fishnet-assets;

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
    ];

    buildInputs = [
      pkgs.stdenv.cc.cc.lib
    ];

    postUnpack = ''
      chmod -R u+w source

      cd source

      shopt -s nullglob
      for f in *.xz; do
        file_output=$(${pkgs.file}/bin/file -b -z "$f")

        if echo "$file_output" | grep -qE '^ELF 64-bit LSB executable, x86-64.*\(XZ compressed data\)$'; then
          ${pkgs.xz}/bin/xz -d "$f"

          unpacked=''${f%.xz}

          autoPatchelf "$unpacked"
          ${pkgs.xz}/bin/xz -z -T 0 -c "$unpacked" > "$f"

          rm "$unpacked"
        fi
      done

      cd ..
    '';

    installPhase = ''
      mkdir -p $out/assets
      cp *.xz $out/assets
    '';
  };

  mergedSrcs = pkgs.symlinkJoin {
    name = "fishnet-with-assets";
    paths = [
      fishnet
      patched_assets
    ];
  };

in naersk.buildPackage {
  pname = "fishnet";
  version = "${fishnet.rev}-assets_${fishnet-assets.rev}";
  src = mergedSrcs;
}
