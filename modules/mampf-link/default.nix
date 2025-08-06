{ config, lib, pkgs, ... }:
with lib;
let cfg = config.awallau.mampf-link;
  
in {
  options.awallau.mampf-link= {
    enable = lib.mkEnableOption "Enable mampf.link";
    # With current packaging this is more of a dream, the port is hardcoded for c# reasons unbeknowns to me
    port = lib.mkOption {
      type = lib.types.port;
      default = 9630;
      description = "Port for Mampf.link to listen on.";
    };
    domain = mkOption {
      type = types.str;
      default = "ma.mpf.link";
      description = "Domain name for mampf.link";
    };
  };

  config = lib.mkIf config.services.myapp.enable {
    systemd.services.myapp = {
      description = "Mampf.link";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${mampf-link}/bin/GroupOrder";
        # Environment = "PORT=${toString config.services.mampf.link.port}";
      };
    };
  };


    services.nginx = {
      enable = true;
      virtualHosts = {
        "${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;
          kTLS = true;
          locations."/" = {
            proxyPass = "http://localhost:9630/";
          };
        };
      };
    };
}