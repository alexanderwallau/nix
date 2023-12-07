{ config, system-config, pkgs, lib, ... }:
with lib;
let cfg = config.awallau.hedgedoc;
in {
  options.awallau.hedgedoc = {
    enable = mkEnableOption "activate hedgedoc";

    domain = mkOption {
      type = types.str;
      default = "hed.ge.doc";
      description = "Domain name for hedgedoc";
    };
  };
  config = mkIf cfg.enable {
    services = {
      hedgedoc = {
        enable = true;
        settings = {
          domain = "${cfg.domain}";
          host = "127.0.0.1";
          port = 3400;
          protocolUseSSL = true;
          useSSL = false;
          db = {
            dialect = "sqlite";
            storage = "/var/lib/hedgedoc/db.sqlite";
          };
        };
      };
      nginx.virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3400";
        };

      };
    };
  };
}
