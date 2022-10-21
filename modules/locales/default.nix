{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.locales;
in
{

  options.awallau.locales = { enable = mkEnableOption "activate kdlocalese"; };

  config = mkIf cfg.enable {

    services.xserver = {
      layout = "de";
      xkbOptions = "eurosign:e";
    };

    # Set your time zone.
    time = {
      timeZone = "Europe/Berlin";
      hardwareClockInLocalTime = true;
    };

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "de";
    };

  };
}
