{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.audiobookshelf;
in
{

  options.awallau.audiobookshelf = {
    enable = mkEnableOption "activate audiobookshelf";

    port = mkOption {
      type = types.port;
      default = 13378;
      description = "Port to listen on";
    };

    domain = mkOption {
      type = types.str;
      default = "audio.book.shelf";
      description = "domain name for audiobookshelf";
    };
  };


  config = mkIf cfg.enable 
    {
      services = {
        audiobookshelf = {
        enable = true;
        port = cfg.port;
        host ="127.0.0.1";
      };

      nginx.virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
         extraConfig = ''
        # Allow any size file to be uploaded
        # Exception here - audiobooks are large and scp is not a option for every user
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
