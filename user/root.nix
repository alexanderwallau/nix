{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.user.awallau;
in
{

  options.awallau.user.root = { enable = mkEnableOption "activate user root"; };

  config = mkIf cfg.enable {

    users.users.root = {
      openssh.authorizedKeys.keyFiles = [
        (pkgs.fetchurl {
          url = "https://github.com/alexanderwallau.keys";
          hash = "sha256-PyMLUgMnj6LN6WqOzG6MVqTewAuwUrh3mc2EerunAuw";
        })
      ];
    };
    nix.settings.allowed-users = [ "root" ];
  };

}
