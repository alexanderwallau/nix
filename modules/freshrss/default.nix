# RSS aggregator and reader
{ config, lib, pkgs, ... }:
let
  cfg = config.awallau.freshrss;
in
{
  options.awallau.freshrss = with lib; {
    enable = lib.mkEnableOption "FreshRSS feed reader";

    defaultUser = mkOption {
      type = types.str;
      default = "admin";
      description = "Default username for FreshRSS.";
      example = "eva";
    };

    passwordFile = mkOption {
      type = types.path;
      description = "Password for the defaultUser for FreshRSS.";
      example = "/run/secrets/freshrss";
    };

    passwordFilePostgres = mkOption {
      type = types.path;
      description = "Password for the Postgresdb for FreshRSS.
                    Keep in mind postgres has an alternative idea of a password file
                    https://www.postgresql.org/docs/current/libpq-pgpass.html
                    hostname:port:database:username:password";
      example = "/run/secrets/freshrssdb";

    };

    language = mkOption {
      type = types.str;
      default = "en";
      description = "Default language for FreshRSS.";
      example = "de";
    };
    domain = mkOption {
      type = types.str;
      default = "rss.alexanderwallau.de";
      description = "Domain for FreshRSS.";
      example = "rss.alexanderwallau.de";
    };
  };

config = lib.mkIf cfg.enable {

    services = {
      freshrss = {
        enable = true;
        defaultUser = "${cfg.defaultUser}";
        passwordFile = "${cfg.passwordFile}";
        baseUrl = "https://${cfg.domain}";
        authType = "http_auth";

        database = {
          host = "/var/run/postgresql";
          type = "pgsql";
          name = "freshrss";
          user = "freshrss";
        };

      };
      # more postgres stuff see down below
      postgresql = {
      ensureUsers = [{
        name = "freshrss";
        ensureDBOwnership = true;
      }];
      ensureDatabases = [ "freshrss" ];
    };
      # Based on: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/web-apps/freshrss.nix
      # And https://git.kempkens.io/daniel/dotfiles/src/branch/master/system/nixos/freshrss.nix
      nginx.virtualHosts."${cfg.domain}" = {
        http3 = true;
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
        '';
        root = "${config.services.freshrss.package}/p";
        # php files handling
        # this regex is mandatory because of the API
        locations."~ ^.+?\.php(/.*)?$".extraConfig = ''
          fastcgi_pass unix:${config.services.phpfpm.pools.${config.services.freshrss.pool}.socket};
          fastcgi_split_path_info ^(.+\.php)(/.*)$;
          # By default, the variable PATH_INFO is not set under PHP-FPM
          # But FreshRSS API greader.php need it. If you have a “Bad Request” error, double check this var!
          # NOTE: the separate $path_info variable is required. For more details, see:
          # https://trac.nginx.org/nginx/ticket/321
          set $path_info $fastcgi_path_info;
          fastcgi_param PATH_INFO $path_info;
          include ${config.services.nginx.package}/conf/fastcgi_params;
          include ${config.services.nginx.package}/conf/fastcgi.conf;
        '';

        locations."/" = {
          tryFiles = "$uri $uri/ index.php";
          index = "index.php index.html index.htm";
        };
      };
    };
    systemd.services.phpfpm-freshrss.after = [ "postgresql.service" ];
  };

}
