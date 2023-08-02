{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.openssh;
in
{

  options.awallau.openssh = { enable = mkEnableOption "activate openssh"; };

  config = mkIf cfg.enable {

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      startWhenNeeded = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

  };
}
