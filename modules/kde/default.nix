{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.kde;
in
{

  options.awallau.kde = { enable = mkEnableOption "activate kde"; };

  config = mkIf cfg.enable {

    # Enable networkmanager
    networking.networkmanager.enable = true;

    # enable the Plasma 6 Desktop Environment.
    services = {
      xserver = {
        enable = true;
        displayManager.sddm.enable = true;
      };
      desktopManager.plasma6 = {
        enable = true;
        # enable the kde applications
      };
    };
    # exclude some packages from plasma5
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      gwenview
      oxygen
      khelpcenter
      # konsole # we should not remove konsole before we have a replacement
      plasma-browser-integration
      #print-manager
    ];
    # see https://nixos.wiki/wiki/KDE#GTK_themes_are_not_applied_in_Wayland_applications
    programs.dconf.enable = true;

  };
}
