{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.mealie;
in
{

  options.awallau.mealie = {
    enable = mkEnableOption "activate mealie";

    port = mkOption {
      type = types.port;
      default = 2467;
      description = "Port to listen on";
    };

    domain = mkOption {
      type = types.str;
      default = "me.al.ie";
      description = "domain name for mealie";
    };
  };

  config = lib.mkIf cfg.enable {

    sops.secrets = {
      "mealie" = { };
    };

    services = {
      mealie = {
        enable = true;
        port = cfg.port;

        settings = {
          # TODO Add SMTP Config
          # wait on https://github.com/NixOS/nixpkgs/pull/476826
          # OIDC configuration
          OIDC_AUTH_ENABLED = true;
          # For unintuitive reasons this needs to create an intermitten "account" to then use the application
          #OIDC_SIGNUP_ENABLED = true;
          ALLOW_SIGNUP = true;
          OIDC_AUTO_REDIRECT = true;
          OIDC_USER_CLAIM = "preferred_username";
          OIDC_CLIENT_ID = "mealie";
          # OIDC_CLIENT_SECRET provided via sops
          # For Reasons the deafault Keycloak group mapping add a "/" imagine having an app with non usable logging..
          OIDC_ADMIN_GROUP = "/mealie_admins";
          OIDC_USER_GROUP = "mealie_users";
          OIDC_CONFIGURATION_URL =
            # Leaving this plaintext, would have been not that hard to guess
            "https://sso.alexanderwallau.de/realms/alexanderwallau/.well-known/openid-configuration";
          OIDC_PROVIDER_NAME = "alexanderwallau.de";
          # Some Gunicorn Basics
          MAX_WORKERS = 1;
          WEB_CONCURRENCY = 1;
          LOG_LEVEL = "warning";
          # The Thing is not smart enough to guess that....
          TZ = "Europe/Berlin";
        };

        credentialsFile = config.sops.secrets."mealie".path;
        # Automatic PostgreSQL provisioning, very nice
        database.createLocally = true;
      };

      nginx = {
        recommendedOptimisation = true;
        recommendedTlsSettings = true;
        recommendedProxySettings = true;
        virtualHosts.${cfg.domain} = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.mealie.port}";
          };
          extraConfig = ''
            client_max_body_size 256M;
          '';
        };
      };
    };
  };

}

