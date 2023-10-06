{ lib, pkgs, config, alexanderwallau-keys, ... }:
with lib;
let cfg = config.awallau.user.root;
in
{

  options.awallau.user.root = {
    enable = mkEnableOption "activate user root";
  };

  config = mkIf cfg.enable {

    users.users.root = {
      openssh.authorizedKeys = { keyFiles = [ alexanderwallau-keys ]; };
    };
    nix.settings.allowed-users = [ "root" ];
  };

}
