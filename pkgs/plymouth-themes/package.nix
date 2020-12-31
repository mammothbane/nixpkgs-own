{
  pkgs,
  plymouth-themes,
  ...
}:

let
  lib = pkgs.lib;
  stdenv = pkgs.stdenv;
  breakpointHook = pkgs.breakpointHook;

  themes = builtins.readDir plymouth-themes;

  mkPackage = { name, path, ... }:
    stdenv.mkDerivation {
      pname = "plymouth-themes-${name}";
      version = plymouth-themes.rev;

      src = plymouth-themes;

      installPhase = ''
        cd ${path}

        if [ ! -e "${name}.script" ]; then
          echo "${name} lacking script file" >&2
          exit 1
        fi

        if grep -qE '/usr|/share|/lib' "${name}.script"; then
          echo "${name} script file appears to refer to fhs env" >&2
          exit 1
        fi

        if [ ! -e "${name}.plymouth" ]; then
          echo "${name} lacks plymouth file" >&2
          exit 1
        fi

        echo "${name} ok" >&2

        mkdir -p  "$out/share/plymouth/themes"
        cp -R .   "$out/share/plymouth/themes/${name}"
        cd        "$out/share/plymouth/themes/${name}"

        chmod -R u+w .

        rm -f ${name}.plymouth
        rm -f LICENSE

        echo generating plymouth file: >&2

        tee "${name}.plymouth" >&2 <<EOF
        [Plymouth Theme]
        Name=${name}
        ModuleName=script

        [script]
        ImageDir=$out/share/plymouth/themes/${name}
        ScriptFile=$out/share/plymouth/themes/${name}.script
        EOF
      '';
    };

  isThemeDir = dir: with builtins;
  let
    name = baseNameOf dir;
    files = readDir dir;
    regularFiles = filter (filename: files.${filename} == "regular") (attrNames files);

    hasPlymouth = lib.any (filename: filename == "${name}.plymouth")  regularFiles;
    hasScript   = lib.any (filename: filename == "${name}.script")    regularFiles;
  in name != "templates" && hasPlymouth && hasScript;

  findThemes = rootDir: with builtins;
  let
    files     = readDir rootDir;
    dirNames  = filter (filename: files.${filename} == "directory") (attrNames files);
    dirs      = map (x: unsafeDiscardStringContext "${rootDir}/${x}") dirNames;

    childThemes =
      foldl'
      (acc: x:
        let
          relPath = lib.removePrefix plymouth-themes x;
          newThemeDirs = if isThemeDir x then { ${baseNameOf x} = relPath; } else findThemes x;
        in acc // newThemeDirs)

      {}
      dirs;
  in if isThemeDir rootDir then [rootDir] else childThemes;

  themeDirs = findThemes plymouth-themes;

in lib.mapAttrs (name: path: mkPackage { inherit name path; }) themeDirs
