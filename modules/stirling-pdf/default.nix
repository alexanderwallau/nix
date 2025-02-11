{ config, system-config, pkgs, lib, ... }:
with lib;
let cfg = config.awallau.stirling-pdf;
in {
  options.awallau.stirling-pdf = {
    enable = mkEnableOption "activate stirling-pdf";
    
    port = mkOption {
      type = types.int;
      default = 7264;
      description = "port to run the application on";
    };
    domain = mkOption {
      type = types.str;
      default = "stir.ling.pdf";
      description = "domain name for stirling-pdf";
    };
  };

  config = mkIf cfg.enable {
    services = {
      stirling-pdf = {
        enable = true;
        environment = { 
          SERVER_PORT = cfg.port; 
          };
      };
      nginx.virtualHosts = {
          "${cfg.domain}" = {
            enableACME = true;
            forceSSL = true;
            extraConfig = ''
              allow 192.168.69.0/24;
              deny all;
              '';
            locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            };
          };
        };
    };
  };
}
