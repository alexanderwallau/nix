{ lib, config, ... }:
with lib;
let
  cfg = config.awallau.containers.chartdb;
in
{
  options.awallau.containers.chartdb = {
    enable = mkEnableOption "activate ChartDB";

    port = mkOption {
      type = types.port;
      default = 7270;
      description = "Local port to expose ChartDB on.";
    };

    domain = mkOption {
      type = types.str;
      description = "Domain name for ChartDB.";
      example = "chartdb.example.com";
    };
  };


  config = mkIf cfg.enable {

    virtualisation.oci-containers.containers.chartdb = {
      autoStart = true;
      image = "ghcr.io/chartdb/chartdb";
      ports = [ "127.0.0.1:${toString cfg.port}:80" ];
      environment = {
        #If you by chance want some AI Insights you can even use local models
        # OPENAI_API_ENDPOINT = 
        # LLM_MODEL_NAME = 

        # Those two are per default false, tells you a lot Imo
        HIDE_CHARTDB_CLOUD = "true";
        DISABLE_ANALYTICS = "true";
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          allow 192.168.69.0/24;
          allow 192.168.178.0/24;
          deny all;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };
  };


}
