{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.bluetooth;
in
{

  options.awallau.bluetooth = {
    enable = mkEnableOption "activate bluetooth";
  };

  config = mkIf cfg.enable {

    hardware.bluetooth = { enable = true; };

    services.blueman.enable = true;
  };
}