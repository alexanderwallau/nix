{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.sound;
in
{

  options.awallau.sound = { enable = mkEnableOption "activate sound"; };

  config = mkIf cfg.enable {

    # Enable sound.
    sound.enable = true;
    hardware.pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };

    environment.systemPackages = with pkgs; [ pavucontrol ];

    users.extraUsers.awallau.extraGroups = [ "audio" ];

  };
}
