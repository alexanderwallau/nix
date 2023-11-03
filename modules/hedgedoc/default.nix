{ config, pkgs, lib, ... }:
with lib;
let cfg = config.awallau.hedgedoc;
in {
  options.awallau.hedgedoc.enable = mkEnableOption "activate hedgedoc";
  config = mkIf cfg.enable {
    services = {
      hedgedoc = {
        enable = true;
        settings = {
          domain = "md.alexanderwallau.de";
          port = 3400;
          protocolUseSSL = true;
          useSSL = false;
#          minio = {
#            accessKey = builtins.readFile /var/src/secret/hedgedoc/s3_access_key_id;
#            endPoint = "s3.alexanderwallau.de";
#            secretKey = builtins.readFile /var/src/secret/hedgedoc/s3_secret_access_key;
#            };
        s3bucket = "hedgedoc";
        db = {
            dialect = "sqlite";
            storage = "/var/lib/hedgedoc/db.hedgedoc.sqlite";
          };
        };
      };
      nginx.virtualHosts."md.alexanderwallau.de" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "127.0.0.1:3400/";
        };
      };
    };

  };
}