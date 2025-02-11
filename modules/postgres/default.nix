{lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.postgres;
in
{
  # Assumpions for this config:
  # 1. you open the Firewall on a wg0 interface --> if not open firewall but for the love of god enable ssl
  # 2. Special in this case pg admin will be used to hot spare the dbs since this functionality hasnt been translated terribly well if at all  to nixos
  options.awallau.postgres = {
    enable = mkEnableOption "activate postgres";

    port = mkOption {
      type = types.int;
      default = 5432;
      description = ''
        The port on which the postgres server will listen.
      '';
  
  };
  };

  config = mkIf cfg.enable {
    
      services = {
        postgresql = {
        enable = true;
        enableTCPIP = true;
        # Hard code that one, one could make an option but this is really not necessary
       # dataDir = "/var/run/postgres";
        settings = {
          port = cfg.port;
          log_connections = true;
          log_statement = "all";
          logging_collector = true;
          log_disconnections = true;
          log_destination = lib.mkForce "syslog";
          };
      };
      postgresqlBackup = {
        enable = true;
        backupAll = true;
        compression = "zstd";
        compressionLevel = 11;
        location = "/var/lib/postgres";
      };

      };
    };
}