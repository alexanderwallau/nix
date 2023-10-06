{ lib, pkgs, config, alexanderwallau-keys, ... }:
with lib;
let cfg = config.awallau.user.root;
in
{

  options.awallau.user.root = {
    enable = mkEnableOption "activate user root";
    # Option for now present because some obscure reference ist still in the  configuration lel
    mayniklas = mkEnableOption "activate user mayniklas";
  };

  config = mkIf cfg.enable {

    users.users.root = {
      openssh.authorizedKeys = { keyFiles = [ alexanderwallau-keys ]; };
    };
    nix.settings.allowed-users = [ "root" ];
  };

}
