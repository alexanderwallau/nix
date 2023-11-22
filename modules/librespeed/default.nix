{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.librespeed;
in
{

  options.awallau.librespeed = {
    enable = mkEnableOption "activate librespeedtest";
    title = mkOption {
      type = types.str;
      default = "LibreSpeed";
      description = ''
        Documentation placeholder
      '';
    };
  };

  config = mkIf cfg.enable {

    virtualisation.oci-containers.containers.librespeedtest = {
      autoStart = true;
      image = "adolfintel/speedtest";
      environment = {
        TITLE = "${cfg.title}";
        ENABLE_ID_OBFUSCATION = "true";
        WEBPORT = "8800";
        MODE = "standalone";
      };
      ports = [ "8800:8800/tcp" ];
    };

    systemd.services.docker-librespeedtest = {
      preStop = "${pkgs.docker}/bin/docker kill librespeedtest";
    };
    networking.firewall.interfaces = {
      "wg0".allowedTCPPorts = [ 8800 ];
      "wg1".allowedTCPPorts = [ 8800 ];
    };
  };

}
