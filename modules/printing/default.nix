{ config, pkgs, lib, ... }:
with lib;
let cfg = config.awallau.printing;
in {
  options.awallau.printing.enable = mkEnableOption "activate printing";
  config = mkIf cfg.enable {
    services = {
      printing = {
        # CUPS
        enable = true;
        drivers = [ pkgs.hplipWithPlugin ];
      };
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      ipp-usb.enable = true;
    };

  };
}
