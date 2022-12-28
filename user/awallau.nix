{ lib, pkgs, config, alexanderwallau-keys, ... }:
with lib;
let cfg = config.awallau.user.awallau;
in
{

  options.awallau.user.awallau = { enable = mkEnableOption "activate user awallau"; };

  config = mkIf cfg.enable {

    users.users.awallau = {
      isNormalUser = true;
      home = "/home/awallau";
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keyFiles = [ alexanderwallau-keys ];
    };
    users.extraUsers.awallau.extraGroups = mkIf config.virtualisation.docker.enable [ "docker" ];
    nix.settings.allowed-users = [ "awallau" ];
  };

}
