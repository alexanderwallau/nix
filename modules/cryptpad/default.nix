# RSS aggregator and reader
{ config, lib, pkgs, ... }:
let
  cfg = config.awallau.cryptpad;
in
{
  options.awallau.cryptpad = with lib; {
    enable = lib.mkEnableOption "Cryptpad - a collaboration suite that is end-to-end-encrypted and open-source ";

    domain = mkOption {
      type = types.str;
      example = "https://cryptpad.example.com";
      default = "";
      description = "This is the URL that users will enter to load your instance";
          };
    httpSafeOrigin = mkOption {
      type = types.nullOr types.str;
      example = "https://cryptpad-ui.example.com. Apparently optional but recommended.";
      description = "Cryptpad sandbox URL";
          };
    port = mkOption {
      default = 3001;
      description = "Port on which the Node.js server should listen";
      };
      websocketPort = mkOption {
      default = 3002;
      description = "Port for the websocket that needs to be separate";
      };
      adminKeys = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "List of public signing keys of users that can access the admin panel";
        example = [ "[cryptpad-user1@my.awesome.website/YZgXQxKR0Rcb6r6CmxHPdAGLVludrAF2lEnkbx1vVOo=]" ];
        };
  };

  config = lib.mkIf cfg.enable {
    services = {
      cryptpad = {
        enable = true;
        settings = {
          httpUnsafeOrigin  = "https://${cfg.domain}";
          httpSafeOrigin = "https://${cfg.httpSafeOrigin}";
          httpAdress =  "0.0.0.0";
          httpPort = cfg.port;
          #adminKeys = "${cfg.adminKeys}";
        };
      };


    nginx.virtualHosts ={
      "${cfg.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${builtins.toString cfg.port}";
      };
      locations."/cryptpad_websocket" = {
        proxyPass = "http://localhost:${builtins.toString cfg.port}/";
        proxyWebsockets = true;
      };
    }; 
    "${cfg.httpSafeOrigin}" = {
      enableACME = true;
      forceSSL = true;
      locations."/cryptpad_websocket" = {
        proxyPass = "http://localhost:${builtins.toString cfg.port}/";
        proxyWebsockets = true;
      };
    };
  };
};
};
}
