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
     i18n.extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
    console = {
      font = "Lat2-Terminus16";
      keyMap = "de";
    };

  };
}
