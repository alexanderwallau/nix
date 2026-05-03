{ config, lib, pkgs, ... }:
let
  cfg = config.awallau.davis;
in
{
  options.awallau.davis = with lib; {
    # More secrets than Options, very tasteful in theory the admin login could be a variable we all know I wont do it....
    enable = lib.mkEnableOption "Davis, somehow the least worst calender Service ";
    domain = mkOption {
      type = types.str;
      example = "ca.len.der";
      default = "";
      description = "Domain for this";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "davis-admin-pass" = { };
      "davis-app-secret" = { };
      "davis-dsn" = { };
    };
    services = {
      davis = {
        enable = true;
        hostname = cfg.domain;
        dataDir = "/var/lib/davis"; # The defaukt is there but this may or may not change
        adminLogin = "davis-admin";
        adminPasswordFile = config.sops.secrets."davis-admin-pass".path;
        appSecretFile = config.sops.secrets."davis-app-secret".path;
        # We 'll use our "own"
        database = {
          driver = "postgresql";
          createLocally = true;
        };
        mail = {
          inviteFromAddress = "calender@alexanderwallau.de";
          dsnFile = config.sops.secrets."davis-dsn".path;
            };

          # PHP FPM do be meh to manually configure so use the builtin options:
          nginx = {
            forceSSL   = true;
            enableACME = true;
          };
        };
      };
      # Makes Sense if we need things from said database...
      systemd.services.phpfpm-davis.after = [ "postgresql.service" ];
    };
  }


