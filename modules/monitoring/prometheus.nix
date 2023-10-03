{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.monitoring.prometheus;
in
{

  options.awallau.monitoring.prometheus = {

    enable = mkEnableOption "monitoring-server setup";

    port = mkOption {
      type = types.port;
      default = 9090;
      description = ''
        Port being used for prometheus
      '';
    };

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address prometheus will listen on";
    };

  };

  config = mkIf cfg.enable {

    services.prometheus = {
      enable = true;
      listenAddress = cfg.listenAddress;
      port = cfg.port;
      # change to domain if exposed through nginx
      webExternalUrl = "http://${cfg.listenAddress}:${toString cfg.port}";
      extraFlags = [ "--log.level=debug" "--storage.tsdb.retention.size=3GB" ];
      retentionTime = "2y";
    };
  };

}
