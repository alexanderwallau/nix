{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.gotify;
in
{
  options.awallau.gotify = {
    enable = lib.mkEnableOption "enable gotify server";
    port = lib.mkOption {
      description = "internal port for gotify server";
      type = lib.types.port;
      default = 34501;
    };
    domain = lib.mkOption {
      description = "domain for gotify server";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "gotify-admin-psk" = { };
    };
    services = {
      gotify = {
      enable = true;
      environment = {
        GOTIFY_SERVER_PORT = cfg.port;
        # That could be done with an option as per we know I wont option this
        GOTIFY_DEFAULTUSER_NAME = "awallau";
      };
      environmentFiles = [ config.sops.secrets."gotify-admin-psk".path ];
      };


    nginx.virtualHosts."${cfg.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        proxyWebsockets = true;
      };
    };
  };
};
}