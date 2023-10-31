{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.librespeedtest;
in
{

  options.awallau.librespeedtest = {
    enable = mkEnableOption "activate librespeedtest";
    port = mkOption {
      type = types.str;
      default = "8080";
    };
    title = mkOption {
      type = types.str;
      default = "LibreSpeed";
    };
  };

  config = mkIf cfg.enable {

    virtualisation.oci-containers.containers.librespeedtest = {
      autoStart = true;
      image = "adolfintel/speedtest";
      environment = {
        TITLE = "${cfg.title}";
        ENABLE_ID_OBFUSCATION = "true";
        WEBPORT = "${cfg.port}";
        MODE = "standalone";
      };
      ports = [ "${cfg.port}:${cfg.port}/tcp" ];
    };

    systemd.services.docker-librespeedtest = {
      preStop = "${pkgs.docker}/bin/docker kill librespeedtest";
    };

  };
}
