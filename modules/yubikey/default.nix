{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.yubikey;
in
{

  options.awallau.yubikey = { enable = mkEnableOption "activate yubikey"; };

  config = mkIf cfg.enable {

    programs.ssh.startAgent = false;

    #    environment.systemPackages = with pkgs; [ yubioath-flutter ];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gnome3";
    };

    # Needed for yubikey to work
    environment.shellInit = ''
      export GPG_TTY="$(tty)"
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
    '';

    # Setup Yubikey SSH and GPG
    services.pcscd.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];

  };
}
