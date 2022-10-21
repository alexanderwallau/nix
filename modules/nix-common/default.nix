{ lib, pkgs, config, nixpkgs, ... }:
with lib;
let cfg = config.awallau.nix-common;
in
{

  options.awallau.nix-common = { enable = mkEnableOption "activate nix-common"; };

  config = mkIf cfg.enable {

    # Allow unfree licenced packages
    nixpkgs.config.allowUnfree = true;

    nix = {
      # Enable nix flakes
      package = pkgs.nixFlakes;

      # Set the $NIX_PATH entry for nixpkgs. This is necessary in
      # this setup with flakes, otherwise commands like `nix-shell
      # -p pkgs.htop` will keep using an old version of nixpkgs.
      # With this entry in $NIX_PATH it is possible (and
      # recommended) to remove the `nixos` channel for both users
      # and root e.g. `nix-channel --remove nixos`. `nix-channel
      # --list` should be empty for all users afterwards
      nixPath = [ "nixpkgs=${nixpkgs}" ];

      # Save space by hardlinking store files
      settings.auto-optimise-store = true;

      # Clean up old generations after 30 days
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.05"; # Did you read the comment?

  };
}
