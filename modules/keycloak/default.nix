{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.keycloak;
in
{
  options.awallau.keycloak = {

    enable = mkEnableOption "activate keycloak";

    domain = mkOption {
      type = types.str;
      default = "key.clo.ak";
      description = "keycloak url";
    };

    port = mkOption {
      type = types.port;
      default = 10480;
      description = "Port being used for connections between NGINX & keycloak";
    };

  };
  config = mkIf cfg.enable {
    sops.secrets ={
      "keycloak" = {
      owner = "postgres";
      group = "postgres";
    };
    };


    services.keycloak = {
      enable = true;
      initialAdminPassword = "unsafe-password";
      database = {
        type = "postgresql";
        username = "keycloak";
        passwordFile = config.sops.secrets."keycloak".path;
        createLocally = true;
        port = 5432;
      };
      settings = {
        hostname = "${cfg.domain}";
        http-relative-path = "";
        hostname-backchannel-dynamic = false;
        http-port = cfg.port;
        http-host = "127.0.0.1";
        http-enabled = true;
        proxy-headers = "xforwarded";
      };


      themes.keywind = pkgs.stdenv.mkDerivation rec {
              name = "keywind";
              src = fetchGit {
                url = "https://github.com/lukin/keywind";
                rev = "6e5ef061bfdaafd7d22a3c812104ffe42aaa55b8";
              };
              installPhase = ''
                mkdir -p $out
                cp -r $src/theme/keywind/* $out/
              '';
            };
    };

    services.nginx.virtualHosts = {
      "${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            extraConfig = ''
              proxy_set_header X-Forwarded-Host $http_host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };
      };
    };
    };

}
