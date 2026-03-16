{ lib, pkgs, config, flake-self, ... }:
with lib;
let
  cfg = config.awallau.stwb-openmensa;
in
{
  imports = [
    flake-self.inputs."stwb-openmensa".nixosModules.default
  ];

  options.awallau.stwb-openmensa = {
    enable = mkEnableOption "activate stwb-openmensa";

    package = mkOption {
      type = types.package;
      default = flake-self.inputs."stwb-openmensa".packages.${pkgs.system}.default;
      description = "Package to run for the stwb-openmensa service.";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port stwb-openmensa listens on.";
    };

    domain = mkOption {
      type = types.str;
      default = "stwb.open.mensa";
      description = "Domain where the webserver is reachable";
    };

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address for the stwb-openmensa service to bind to.";
    };

    refreshTimes = mkOption {
      type = types.listOf types.str;
      default = [ "07:00" "11:00" "11:30" "12:00" "12:30" "13:00" "13:30" ];
      example = [ "06:00" "10:30" "14:30" ];
      description = "Times at which menu data is refreshed.";
    };
  };

  config = mkIf cfg.enable {
    services = {
      stwb-openmensa = {
        enable = true;
        # The module sees this fit, lets try something new
        inherit (cfg) package port listenAddress refreshTimes;
      };

      nginx = {
        virtualHosts.${cfg.domain} = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://${cfg.listenAddress}:${toString cfg.port}";
            recommendedProxySettings = true;
          };
        };
      };
    };
  };
}
