{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.gnome;
in
{

  options.awallau.gnome = { enable = mkEnableOption "activate gnome"; };

  config = mkIf cfg.enable {

    awallau = {
      # NOTE from the original source of this module:
      # There is a reason, I did not enable my wayland module in the original gnome module.
      wayland.enable = mkForce false;
      kde.enable = mkForce false;
      sway.enable = mkForce false;
    };

    services = {
      displayManager.defaultSession = "gnome";
      xserver = {
        # Enable the X11 windowing system.
        enable = true;
        # Enable the GNOME Desktop Environment.
        desktopManager.gnome.enable = true;
        displayManager.gdm.enable = true;
      };
        
        
      gnome = {
        core-developer-tools.enable = true;
        core-os-services.enable = true;
        core-shell.enable = true;
        core-utilities.enable = true;
        gnome-settings-daemon.enable = true;
      };
    };

    environment = {

      gnome.excludePackages = (with pkgs; [
        atomix # puzzle game
        epiphany
        geary
                gnome-initial-setup
        gnome-music
        gnome-photos
        gnome-tour
        hitori # sudoku game
        iagno # go game
        tali # poker game
        yelp
      ]);

      systemPackages = with pkgs.gnomeExtensions; [
        appindicator
        wireguard-indicator
        wireless-hid
        workspace-switcher-manager
      ];
    };

    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  };
}
