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
        openFirewall = cfg.openFirewall;
        host ="127.0.0.1";
      };

      nginx.virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
          proxyWebsockets = true;
        };

      };
      };
    };


}