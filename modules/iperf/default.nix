{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.iperf;
in
{

  options.awallau.iperf = {

    enable = mkEnableOption "activate iperf";

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Open the appropriate ports in the firewall for iperf.
      '';
    };

  };

  config = mkIf cfg.enable {

    services.iperf3 = {
      enable = true;
      openFirewall = false;
      port = 5201;
    };

    networking.firewall = {
      allowedTCPPorts = mkIf cfg.openFirewall [ 5201 ];
      interfaces = { wg0.allowedTCPPorts = [ 5201 ]; };
    };

  };
}