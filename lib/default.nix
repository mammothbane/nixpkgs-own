{ callPackage, lib }:
with lib;

{
  tryCallPackage = path: overrides: if pathExists path then callPackage path overrides else null;

  orDefault = arg: default: if arg != null then arg else default;
}
