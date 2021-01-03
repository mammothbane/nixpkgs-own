{
  pkgs,
  netboot_xyz,
  pciids,
  ipxe,
  pipxe,
  ...
}:

let
  confYaml = pkgs.writeText "conf.yaml" (builtins.toJSON (import ./conf.nix {
    dst = "/build/source/work";
    inherit pciids ipxe pipxe;
  }));

  siteYaml = pkgs.writeText "site.yaml" (builtins.toJSON [{
    hosts = "localhost";
    user = "nixbld";
    roles = [ "netbootxyz" ];
    vars_files = [ "endpoints.yml" "user_overrides.yml" ];
  }]);

  ansible = pkgs.python3Packages.toPythonApplication (pkgs.python3Packages.ansible.overridePythonAttrs (oldAttrs: {
    version = "2.10.4";
  }));

  aarchpkgs = pkgs.crossPkgs "aarch64-linux";

in pkgs.stdenv.mkDerivation {
  pname = "netboot.xyz";
  version = netboot_xyz.rev;

  nativeBuildInputs = with pkgs; [
    breakpointHook
    ansible
    git
    openssl
  ];

  src = netboot_xyz;

  buildPhase = ''
    cp ${confYaml} user_overrides.yml
    cp ${siteYaml} site.yml

    umask 000

    mkdir -p  /build/ansible-home
    mkdir -p  /build/ansible
    mkdir -p  /build/.ansible

    export HOME=/build/ansible-home
    export ANSIBLE_LOCAL_TEMP=/build/ansible

    mkdir -p /build/source/work/var/www/html/ipxe

    cd /build/source
    ansible-playbook -v -i inventory site.yml
  '';

  installPhase = ''
    mkdir -p                                    $out/share/netbootxyz
    chmod -R  u+w                               $out/share
    cp    -R  /build/source/work/var/www/html/* $out/share/netbootxyz
    chmod -R  a-wx+Xr                           $out
  '';
}
