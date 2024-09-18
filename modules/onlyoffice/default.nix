{ config, pkgs, lib, ... }:
with lib;
let cfg = config.awallau.onlyoffice;
in {
  options.awallau.onlyoffice = {
    enable = mkEnableOption "activate onlyoffice";
    port = mkOption {
      type = types.int;
      default = 8234;
      description = "port to run the application on";
    };
    domain = mkOption {
      type = types.str;
      default = "only.offi.ce";
      description = "domain to run the application on";
    };

  };
  config = mkIf cfg.enable {
    services = {
      onlyoffice = {
        enable = true;
        #hostname = cfg.domain;
        port = cfg.port;
      };
      nginx.virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
        };
        extraConfig =''
          allow 192.168.69.0/24;
          allow 192.168.178.0/24;
          allow 202.61.232.46;
          allow 2a03:4000:61:8b27::20;
          allow 2a03:4000:61:94c0::20:6616;
          deny all; # deny all remaining ips
        '';
      };
    };
    };
  }
