fishnet:
{ config, lib, ... }:

let
  cfg = config.services.fishnet;

in {
  options.services.fishnet = with lib; with types; {
    enable = mkEnableOption "fishnet";

    environmentFile = mkOption {
      description = "location of environment file holding FISHNET_KEY=<val> declaration";
      type = str;
    };

    user = mkOption {
      type = str;
      default = "ufishnet";
    };

    group = mkOption {
      type = str;
      default = "gfishnet";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.fishnet = {
      description = "run stockfish for lichess";

      wantedBy = [
        "multi-user.target"
      ];

      bindsTo = [
        "network-online.target"
      ];

      after = [
        "network-online.target"
      ];

      unitConfig = {
        StartLimitBurst = 3;
        StartLimitIntervalSec = "1m";
      };

      serviceConfig = {
        Type = "exec";
        EnvironmentFile = cfg.environmentFile;

        DynamicUser = true;
        User = cfg.user;
        Group = cfg.group;
        SupplementaryGroups = "fishnet";

        StandardInput = "null";

        ExecStart = ''${fishnet}/bin/fishnet --no-conf --cores 1 --user-backlog=0 --system-backlog=0 --key "$FISHNET_KEY"'';

        Restart = "always";
        RestartSec = "10s";

        TimeoutStopSec = "10s";

        CPUQuota = "100%";
        CPUSchedulingPolicy = "idle";
        CPUAffinity = "3";
        Nice = 19;

        MemoryHigh = "80M";
        MemoryMax = "100M";

        ProtectSystem = "strict";
        ProtectProc = "noaccess";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;

        PrivateDevices = true;
        PrivateUsers = true;
        PrivateMounts = true;

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        MemoryDenyWriteExecute = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        KeyringMode = "private";

        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
      };
    };

    users.groups.fishnet = {};
  };
}
