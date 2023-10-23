{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.awallau.sway;
  sway-overlay = (final: prev: {
    wlay = pkgs.unstable.wlay;
  });
in
{

  options.awallau.sway = {
    enable = mkEnableOption "activate sway";
  };

  config = mkIf cfg.enable {

    nixpkgs = { overlays = [ sway-overlay ]; };

    # make sure wayland quirks are set and KDE is being disabled
    awallau = {
      wayland.enable = true;
      kde.enable = mkForce false;
    };

    home-manager.users."${config.awallau.home-manager.username}" = {
      imports = [{ nixpkgs.overlays = [ sway-overlay ]; }];
      # enable sway related home manager modules
      awallau.programs = {
        sway.enable = true;
        swaylock.enable = true;
      };
    };

  };
}
