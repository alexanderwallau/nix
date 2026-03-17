{ lib, config, ... }:
with lib;
let
  cfg = config.awallau.containers.bichon;
in
{
  options.awallau.containers.bichon = {
    enable = mkEnableOption "activate bichon";

    port = mkOption {
      type = types.port;
      default = 15630;
      description = "Port to expose Bichon on locally.";
    };

    domain = mkOption {
      type = types.str;
      default = "bichon.alexanderwallau.de";
      description = "Domain name for the Bichon web interface.";
    };

    directory = mkOption {
      type = types.str;
      default = "/var/lib/bichon";
      description = "Directory to store Bichon persistent data.";
      example = "/data/bichon";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.directory} 0700 root root - -"
    ];

    virtualisation.oci-containers.containers.bichon = {
      autoStart = true;
      # Pinning Docker Containers, nah
      image = "rustmailer/bichon:latest";
      ports = [ "${builtins.toString cfg.port}:15630/tcp" ];
      volumes = [ "${cfg.directory}:/data" ];
      environment = {
        BICHON_ROOT_DIR = "/data";
        # Better logs are better
        BICHON_LOG_LEVEL = "info";
        BICHON_ANSI_LOGS = "true";
        BICHON_LOG_TO_FILE = "true";
        
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts.${cfg.domain} = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          allow 192.168.69.0/24;
          allow 192.168.178.0/24;
          deny all;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
        };
        
      };
    };
  };
}
