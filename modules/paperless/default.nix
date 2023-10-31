{ config, pkgs, lib, ... }:
with lib;
let cfg = config.awallau.paperless;
in {
  options.awallau.paperless.enable = mkEnableOption "activate paperless";
  config = mkIf cfg.enable {
    services.paperless = {
      enable = true;
      passwordFile = "/var/src/secret/paperless";
      dataDir = "/var/lib/paperless";
      extraConfig = {
        PAPERLESS_ADMIN_USER = "awallau";
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_OCR_USER_ARGS = builtins.toJSON {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
      };
    };
    services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      virtualHosts."archive.alexanderwallau.de" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:28981/";
          extraConfig = ''
            client_max_body_size 256M;
            allow 192.168.69.0/24;
            deny all;
          '';
        };
      };
    };
  };
}
