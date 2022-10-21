{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.docker;
in
{

  options.awallau.docker = { enable = mkEnableOption "activate docker"; };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [ docker-compose ];

    virtualisation.docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

  };
}
