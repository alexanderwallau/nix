{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.gnome;
in
{

  options.awallau.gnome = { enable = mkEnableOption "activate gnome"; };

  config = mkIf cfg.enable {

    awallau = {
      wayland.enable = true;
      kde.enable = mkForce false;
      sway.enable = mkForce false;
    };

    services.xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Enable the GNOME Desktop Environment.
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    services.gnome = {
      core-developer-tools.enable = true;
      core-os-services.enable = true;
      core-shell.enable = true;
      core-utilities.enable = true;
      gnome-settings-daemon.enable = true;
    };

    environment.systemPackages = with pkgs.gnomeExtensions; [
      appindicator
      wireguard-indicator
      wireless-hid
      workspace-switcher-manager
      yakuake
    ];

    services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];

  };
}
