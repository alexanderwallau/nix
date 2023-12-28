{ config, lib, ... }:
with lib;
let
  cfg = config.awallau.containers.rss-bridge;
  whitelist = builtins.toFile "whitelist.txt" ''*'';
in
{
  options.awallau.containers.rss-bridge = {
    enable = lib.mkEnableOption "rss-bridge";

    domain = mkOption {
      type = types.str;
      default = "rss-brigde.alexanderwallau.de";
      description = "Domain for Rss-Brige";
      example = "rss.brid.ge";
    };
    port = mkOption {
      type = types.str;
      default = 8089;
    };
  };


  config = lib.mkIf cfg.enable {


    virtualisation.oci-containers.containers = {

      rss-bridge = {
        image = "rssbridge/rss-bridge";
        autoStart = true;
        ports = [ "${cfg.port}:80" ];
        volumes = [
          "${whitelist}:/app/whitelist.txt"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--log-opt=tag='rss-brige'"
        ];
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
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            extraConfig = ''
              client_max_body_size 256M;
            '';
          };
        };
      };
    };
  };
}
