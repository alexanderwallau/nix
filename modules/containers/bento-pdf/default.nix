{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.containers.bento-pdf;
in
{

  options.awallau.containers.bento-pdf = {
    enable = mkEnableOption "activate bento-pdf";

    port = mkOption {
      type = types.port;
      default = 7264; # default is 8080, this is a random number
      description = "port to listen on";
    };

    domain = mkOption {
      type = types.str;
      default = "ben.to.pdf";
      description = "domain name for bento-pdf";
    };

    disableIPv6 = mkOption {
      type = types.bool;
      default = true;
      description = "For IPv4-only environments";

    };
  };
  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.bento-pdf = {
      autoStart = true;
      image = "bentopdf/bentopdf:latest";
      environment = {
        DISABLE_IPV6 = builtins.toString cfg.disableIPv6;
      };
    ports = [ "${builtins.toString cfg.port}:8080/tcp" ];
    };

    # Since everythin happens clientside we can make this world opens
    services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          # Uhh IPv6
          locations."/" = {
            proxyPass = "http://[::]:${builtins.toString cfg.port}";
            extraConfig = ''
              client_max_body_size 256M;
            '';
          };
        };

      };
    };
  };
}
