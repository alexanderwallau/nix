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
    
    # Since Things across the network may use other hosts dbs and the syncing is only available  via the wireguard net we wait on it a bit during boot
     # Elegantly copied from: https://github.com/NixOS/infra/blob/main/build/haumea/postgresql.nix
    systemd.services.postgresql = {
    after = [ "wireguard-wg0.service" ];
    requires = [ "wireguard-wg0.service" ];
    };  
      services = {
        postgresql = {
        enable = true;
        enableTCPIP = true;
        # Hard code that one, one could make an option but this is really not necessary
        # dataDir = "/var/run/postgres";

        settings = {
          port = cfg.port;
          # logging options
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
      # seems reasonably practical since some manual data movement ist always required
      users.extraUsers.awallau.extraGroups = [ "postgres" ];
      environment.systemPackages = with pkgs;
      [
        pgloader
        postgresql
      ];
      # enable these pkgs for all users serves the benefit of beeing able to import data from the various systemd-service accounts 
    };
}