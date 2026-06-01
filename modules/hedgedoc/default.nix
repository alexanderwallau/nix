{ config, system-config, pkgs, lib, ... }:
with lib;
let cfg = config.awallau.hedgedoc;
in {
  options.awallau.hedgedoc = {
    enable = mkEnableOption "activate hedgedoc";

    domain = mkOption {
      type = types.str;
      default = "hed.ge.doc";
      description = "Domain name for hedgedoc";
    };
  };
  config = mkIf cfg.enable {

    sops.secrets = {
      "hedgedoc-oidc-secret" = { 
        # For reasons this needs to be very explicitly set, using clan would make this more elegrant
        # I digress
        owner = config.systemd.services.hedgedoc.serviceConfig.User;
      };
    };
    
    services = {
      hedgedoc = {
        enable = true;
        settings = {
          domain = "${cfg.domain}";
          host = "127.0.0.1";
          port = 3400;
          environmentFile = config.sops.secrets."hedgedoc-oidc-secret".path;

          protocolUseSSL = true;
          useSSL = false;

          allowGravatar = false;
          allowAnonymous = false;
          allowAnonymousEdits = true;
          allowAnonymousUploads = true;
          allowFreeUrl = true;
          requireFreeURLAuthentication = true;
        
          defaultPermissions = "limited";

          db = {
          dialect = "postgres";
          host = "/run/postgresql/";
          };
        # Fun with Auth 
        email = false;
        oauth2 = {
          baseUrl = "https://sso.alexanderwallau.de";
          providerName = "AlexanderWallau.de";
          clientID = "hedgedoc";
          # This gets replacesd at runtime or so
          clientSecret = "$OIDC_SECRET";
          scope = "openid email profile";
          # Or to be fail reading the keycloak docs and taking -2 intelligent guesses
          userProfileURL = "https://sso.alexanderwallau.de/realms/alexanderwallau/protocol/openid-connect/userinfo";
          tokenURL = "https://sso.alexanderwallau.de/realms/alexanderwallau/protocol/openid-connect/token";
          authorizationURL = "https://sso.alexanderwallau.de/realms/alexanderwallau/protocol/openid-connect/auth";
          userProfileUsernameAttr = "preferred_username";
          userProfileDisplayNameAttr = "name";
          userProfileEmailAttr = "email";
        };

        };
      };
      nginx.virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3400";
          proxyWebsockets = true;
        };
        locations."/robots.txt" = {
            extraConfig = ''
              add_header  Content-Type  text/plain;
              return 200 "User-agent: *\nDisallow: /\n";
            '';
          };

      };
      # Move to postgres
      postgresql = {
      ensureUsers = [
        {
          name = "hedgedoc";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "hedgedoc" ];
    };
  };

  systemd.services= {
    hedgedoc.preStart = lib.mkBefore ''
      export OIDC_SECRET="$(cat ${config.sops.secrets."hedgedoc-oidc-secret".path})"
      '';
    };
};
}