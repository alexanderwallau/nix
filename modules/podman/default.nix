{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.podman;
in {

  options.awallau.podman = {

    enable = mkEnableOption "activate podman";

  };
  config = mkIf cfg.enable {
    virtualisation = {
      podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };
}
