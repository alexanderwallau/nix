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
    Port = mkOption {
      type = types.int;
      default = 3001;
      description = "Port on which the Node.js server should listen";
      };
      websocketPort = mkOption {
      type = types.int;
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
      cryptpad.settings = {
        httpUnsafeOrigin  = "${cfg.domain}";
        httpsSafeOrigin = "${cfg.httpSafeOrigin}";
        httpPort = "${cfg.Port}";
        websocketPort = "${cfg.websocketPort}";
        adminKeys = "${cfg.adminKeys}";
      };


    nginx.virtualHosts."${cfg.domain}" = {
      locations."/".proxyPass = "http://127.0.0.1:3001";
    };
  };
};
}
