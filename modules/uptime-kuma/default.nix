{ lib, config, ... }:
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
    services = {
      uptime-kuma = {
        enable = true;
        settings = {
          HOST = "$127.0.0.1";
          PORT = "3001";
        };
      };
      nginx = {
        enable = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        virtualHosts."${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "127:0.0.1:3001";
          };
        };
      };
    };
  };
}
