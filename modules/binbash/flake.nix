{
  description = "create a /bin/bash for compat";

  outputs = { self }: {
    nixosModule = { config, lib, ... }:
      with lib;

      {
        options = {
          environment.binbash = mkOption {
            default = null;

            example = literalExample ''
              "''${pkgs.bash}/bin/bash"
            '';

            type = with types; nullOr path;

            description = ''
              A bash executable linked to /bin/bash.
            '';
          };
        };

        config = {
          system.activationScripts.binbash = if config.environment.binbash != null
          then ''
            mkdir -m 0755 -p /bin
            ln -sfn ${config.environment.binbash} /bin/.bash.tmp
            mv /bin/.bash.tmp /bin/bash  # atomic replacement
          ''
          else ''
            rm -f /bin/bash
            rmdir --ignore-fail-on-non-empty /bin
          '';
        };
      };
  };
}
