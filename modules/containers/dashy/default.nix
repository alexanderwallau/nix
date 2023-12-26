{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.awallau.containers.dashy;

in
{
  options.awallau.containers.dashy = {
    enable = lib.mkEnableOption "dashy";

    domain = mkOption {
      type = types.str;
      default = "fsdash.awll.de";
      description = "Domain for Dashy";
      example = "d.as.hy";
    };

    configFile = mkOption {
      type = types.str;
      default = "/etc/nixos/dashy.yml";
      description = "Path to the config file.";
      example = "/etc/nixos/dashy.yml";
    };
    port = mkOption {
      type = types.str;
      default = 8081;
    };
  };

  config = mkIf cfg.enable {
    # Dashy docker service
    # One could also build this into a nix package and use it directly with nix style options for the conf.yml
    # but for reasons this was not done here!
    virtualisation.oci-containers.containers = {
      dashy = {
        image = "lissy93/dashy";
        environment = {
          TZ = "Europe/Berlin";
        };
        volumes = [
          "${cfg.configFile}:/app/public/conf.yml"
        ];
        ports = [ "${cfg.port}:80" ];
      };
    };


    services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            extraConfig = ''
              client_max_body_size 256M;
            '';
          };
        };
      };
    };
  };

}
