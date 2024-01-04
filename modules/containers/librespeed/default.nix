{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.containers.librespeed;
in
{

  options.awallau.containers.librespeed = {
    enable = mkEnableOption "activate librespeedtest";

    port = mkOption {
      type = types.port;
      default = 5894;
      description = "port to listen on";
    };

    domain = mkOption {
      type = types.str;
      default = "libre.spped.test";
      description = "domain name for librespeed";
    };

    title = mkOption {
      type = types.str;
      default = "LibreSpeed";
      description = "title to display";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.librespeedtest = {
      autoStart = true;
      image = "adolfintel/speedtest";
      environment = {
        TITLE = "${cfg.title}";
        ENABLE_ID_OBFUSCATION = "true";
        WEBPORT = builtins.toString cfg.port;
        MODE = "standalone";
      };
      ports = [ "${builtins.toString cfg.port}:${builtins.toString cfg.port}/tcp" ];
    };



    services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "${cfg.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
            extraConfig = ''
              client_max_body_size 256M;
            '';
          };
        };

      };
    };
  };
}
