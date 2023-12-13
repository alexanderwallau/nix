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
      package = pkgs.postgresql_15_jit;
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

      authentication = ''
        host all all 192.168.69.0/24 md5
        host all all 192.168.178.0/24 md5
      '';
    };
    # When finally finished deploying wireguard, we can remove this
    #networking.firewall.interfaces."wg0".allowedTCPPorts = [ 5432 ];
  };
}
