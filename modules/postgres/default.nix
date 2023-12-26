{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.postgres;
in
{

  options.awallau.postgres = {

    enable = mkEnableOption "activate postgrs";

  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql;
      enableJIT = true;
      enableTCPIP = true;

      settings = {
        full_page_writes = "off";
        wal_init_zero = "off";
        wal_recycle = "off";

        track_activities = "on";
        track_counts = "on";
        autovacuum = "on";
      };
      ensureDatabases = [ "tandoor" "freshrss" "hedgedoc" ];

      ensureUsers = [
        {
          name = "freshrss";
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
        {
          name = "tandoor";
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
        {
          name = "hedgedoc";
          ensureDBOwnership = true;
          ensureClauses.login = true;
        }
      ];
      #
      #initialScript = pkgs.writeText "pg-init.sql" ''
      #  ALTER DATABASE freshrss OWNER TO freshrss;
      #  ALTER DATABASE tandoor OWNER TO tandoor;
      #  ALTER DATABASE hedgedoc OWNER TO hedgedoc;
      #'';
      #identMap = ''
      #  # ArbitraryMapName systemUser DBUser
      #  superuser_map      root       postgres
      #  superuser_map      postgres   postgres
      #
      #  # Let other names login as themselves
      #  superuser_map      /^(.*)$    \1
      #'';
    };
    networking.firewall.interfaces."wg0".allowedTCPPorts = [ 5432 ];
  };
}




