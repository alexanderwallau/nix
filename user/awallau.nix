{ lib, pkgs, config, ... }:
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
      openssh.authorizedKeys.keyFiles = [
        (pkgs.fetchurl {
          url = "https://github.com/alexanderwallau.keys";
          hash = "sha256-PyMLUgMnj6LN6WqOzG6MVqTewAuwUrh3mc2EerunAuw";
        })
      ];
    };
    users.extraUsers.awallau.extraGroups = mkIf config.virtualisation.docker.enable [ "docker" ];
    nix.settings.allowed-users = [ "awallau" ];
  };

}
