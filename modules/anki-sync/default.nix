# Anki sync
# TODO Make more options
{ config, lib, pkgs, ... }:
let
  cfg = config.awallau.anki-sync;
in
{
  options.awallau.anki-sync = with lib; {
    enable = lib.mkEnableOption "Private anki sync server";

    User = mkOption {
      type = types.str;
      default = "admin";
      description = "User for the service";
      example = "eva";
    };

    passwordFile = mkOption {
      type = types.path;
      description = "Password for the User.";
      example = "/run/secrets/anki-sync";
    };

      domain = mkOption {
      type = types.str;
      default = "an.ki.sync";
      description = "Domain for AnkiSync.";
      example = "as.alexanderwallau.de";
    };

  };
    config = lib.mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = [ 22701 ];
      services = {
        anki-sync-server = {
          enable = true;
          openFirewall = true;
          
          baseDirectory = "/var/lib/anki-sync";
          # if not specified this will use ipv6
          address = "127.0.0.1";
          # One could also make that flexible but what else uses this port hart coded?
          port = 27701;
          # Technically one could define many users, maybe in the future if needed
          # Also technically we could sops this but atm idc
          users = [
            {
              username = "${cfg.User}";
              passwordFile = toString cfg.passwordFile;
            }
          ];
        };
        nginx.virtualHosts."${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
              proxyPass = "http://127.0.0.1:27701";
              extraConfig = ''
                client_max_body_size 256M;
              '';
            };
        };
        };
  };
}