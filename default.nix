{ callPackage }:
{
  pkgs = callPackage ./pkgs {};
  lib = callPackage ./lib {};
}
