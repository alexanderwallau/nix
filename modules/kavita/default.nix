{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.kavita;
in
{

  options.awallau.kavita = {
    enable = mkEnableOption "activate kavita";

    port = mkOption {
      type = types.port;
      default = 13378;
      description = "Port to listen on";
    };

    domain = mkOption {
      type = types.str;
      default = "e.book.reader";
      description = "domain name for kavita";
    };
  };

    config = mkIf cfg.enable {
      sops.secrets = {
        "kavita" = {
          owner = "kavita";
          group = "kavita";
        };
      };
      services = {
          kavita = {
              enable = true;
              #user = "awallau";
              dataDir = "/var/lib/kavita";
              settings = {
                IpAddresses = "127.0.0.1";
                Port = cfg.port;
                };
              tokenKeyFile = config.sops.secrets."kavita".path;
            };

        nginx.virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          extraConfig = ''
          # Allow any size file to be uploaded
          # Exception here - ebooks may be large are large and scp is not a option for every user
          # Set to a value such as 1000m; to restrict file size to a specific value
          client_max_body_size 0;
          # To disable buffering
          proxy_buffering off;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
          proxyWebsockets = true;
        };

      };
      };
    };

}  