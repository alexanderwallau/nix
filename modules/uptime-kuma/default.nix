{ lib, config, pkgs, ... }:
with lib; let
  cfg = config.awallau.uptime-kuma;
in
{
  options.awallau.uptime-kuma = {

    enable = mkEnableOption "activate uptimekuma";

    domain = mkOption {
      type = types.str;
      default = "up.time.kuma";
      description = "Domain name for uptime-kuma";
    };

  };


  config = mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      settings = {
        HOST = "127.0.0.1";
        PORT = "56473";
      };
    };



    services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;

      virtualHosts = {
        "${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;
          kTLS = true;
          locations."/" = {
            proxyPass = "http://localhost:${config.services.uptime-kuma.settings.PORT}/";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
