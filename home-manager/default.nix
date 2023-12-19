{ config, pkgs, lib, flake-self, ... }:
with lib;
let cfg = config.awallau.home-manager;
in
{

  options.awallau.home-manager = {

    enable = mkEnableOption "home-manager configuration";

    profile = mkOption {
      type = types.str;
      default = "desktop";
      description = "Profile to use";
      example = "desktop";
    };

    username = mkOption {
      type = types.str;
      default = "awallau";
      description = "Main user";
      example = "lisa";
    };
  };

  config = mkIf cfg.enable {

    # DON'T set useGlobalPackages! It's not necessary in newer
    # home-manager versions and does not work with configs using
    # nixpkgs.config`
    home-manager.useUserPackages = true;

    home-manager.users."${cfg.username}" = {

      imports = [
        {
          nixpkgs.overlays = [
            flake-self.overlays.default
            flake-self.inputs.bonn-mensa.overlays.default
          ];
        }
        ./profiles/${cfg.profile}.nix
      ];
    };

  };
}
