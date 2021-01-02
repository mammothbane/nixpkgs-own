{
  pkgs,
  netboot_xyz,
  pciids,
  ipxe,
  pipxe,
  ...
}:

let
  cacert = builtins.fetchurl {
    url = https://ca.ipxe.org/ca.crt;
    sha256 = "15kwz3liwbdpi8s3v3axaswmp1b3wm3zqps50gmrsiyj4v34fx8d";
  };

  confYaml = pkgs.writeText "conf.yaml" (builtins.toJSON (import ./conf.nix {
    dst = "/build/source/work";
    inherit pciids ipxe pipxe cacert;
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

in pkgs.stdenv.mkDerivation {
  pname = "netboot.xyz";
  version = netboot_xyz.rev;

  nativeBuildInputs = [
    pkgs.breakpointHook
  ];

  buildInputs = with pkgs; [
    perl
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
    export PATH=${ansible}/bin:${pkgs.git}/bin:$PATH

    mkdir -p /build/source/work

    git config --global user.email nixbld@localhost
    git config --global user.name "Nix Builder"

    git init /build/source/work/ipxe.git
    git init /build/source/work/pipxe.git

    cd /build/source/work/ipxe.git
    cp -R ${ipxe}/* ./
    git add .
    git commit -m "dummy commit"
    git apply ${./ipxe-echo.patch}

    cd /build/source/work/pipxe.git
    cp -R ${pipxe}/* ./
    git add .
    git commit -m "dummy commit"

    mkdir -p /build/source/work/usr/src
    cd /build/source/work/usr/src

    git clone --origin origin file:///build/source/work/ipxe.git
    git clone --origin origin file:///build/source/work/pipxe.git

    mkdir -p /build/source/work/usr/src/ipxe/src/config/local

    cd /build/source
    ansible-playbook -v -i inventory site.yml
  '';

  installPhase = ''
    mv /build/source/work/var/www/html $out
  '';
}
