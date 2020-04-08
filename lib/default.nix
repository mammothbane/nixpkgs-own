{ callPackage, lib }:
with lib;

{
  tryCallPackage = path: overrides: if pathExists path then callPackage path overrides else null;
}
