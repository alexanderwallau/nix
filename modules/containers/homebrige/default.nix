{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.containers.homebridge;
in
{
options.awallau.containers.librespeed = {
  enable = mkEnableOption "activate homebridge";

  nginx = mkEnableOption "enable nginx for homebridge";

  port = mkOption {
    type = types.port;
    default = 5894;
    description = "port to listen on";
  };

  domain = mkOption {
    type = types.str;
    default = "libre.spped.test";
    description = "domain name for homebridge";
  };
  interface = mkOption {
    type = types.str;
    default = "end0";
    description = "interface to listen on";
    # This should in be your local lan/wifi interface as using wireguard adds undesirable latency even if the server is in the same network
  };
};

  config = mkIf cfg.enable {
  systemd.tmpfiles.rules = [
    "d /var/lib/homebridge 0755 root root"
  ];

  virtualisation.oci-containers.containers.homebridge = {
  autoStart = true;
    image = "oznu/homebridge";
    environment = {
      "TZ" = "Europe/Berlin";
      "HOMEBRIDGE_CONFIG_UI" = "1";
      "HOMEBRIDGE_CONFIG_UI_PORT" = "${cfg.port}";
    };
    volumes = [
      "/var/lib/homebridge:/homebridge"
    ];
    extraOptions = [
      "--network=host"
    ];
  };
  services.nginx.virtualHosts = mkIf cfg.nginx {
    "${cfg.domain}" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        allow 192.168.69.0/24;
        allow 192.168.178.0/24;
        deny all;
      '';
      locations."/" = { proxyPass = "http://127.0.0.1:${toString cfg.port}"; };
    };

  };

  networking.firewall.interfaces."${cfg.interface}" = {
    allowedTCPPorts = [ 5353 8181 9999  33731 51789
   # Uncomment the port below, if the ui is not behind a reverse proxy
   # ${cfg.port}
    ];
    allowedUDPPorts = [ 5353 ];

    allowedTCPPortRanges = [{ from = 52100; to = 52150; }];
  };
};
}
