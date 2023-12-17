{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.tandoor;
in
{

  options.awallau.tandoor = {

    enable = mkEnableOption "activate tandoor";

    port = mkOption {
      type = types.port;
      default = 8510;
      description = "Port to run tandoor on";
    };

    domain = mkOption {
      type = types.str;
      default = "ta.nd.oor.";
      description = "Domain to run tandoor on";
    };

  };

  config = mkIf cfg.enable {
    services = {
      tandoor-recipes = {
        package = pkgs.tandoor-recipes;
        enable = true;
        port = cfg.port;
        extraConfig = {
          DB_ENGINE = "django.db.backends.postgresql";
          POSTGRES_HOST = "/var/run/postgresql";
          POSTGRES_USER = "tandoor";
          POSTGRES_DB = "tandoor";
          TZ = "Europe/Berlin";
          ENABLE_SIGNUP = 0;
          ENABLE_PDF_EXPORT = 1;
        };
      };

      nginx.virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
        };
      };
    };
  };
}
