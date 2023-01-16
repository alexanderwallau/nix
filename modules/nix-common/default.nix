{ lib, pkgs, config, nixpkgs, flake-self, ... }:
with lib;
let cfg = config.awallau.nix-common;
in
{

  options.awallau.nix-common = {
    enable = mkEnableOption "activate nix-common";
    disable-cache = mkEnableOption "not use binary-cache";
  };

  config = mkIf cfg.enable {

    nix = {
      package = pkgs.nixFlakes;

      # Set the $NIX_PATH entry for nixpkgs. This is necessary in
      # this setup with flakes, otherwise commands like `nix-shell
      # -p pkgs.htop` will keep using an old version of nixpkgs.
      # With this entry in $NIX_PATH it is possible (and
      # recommended) to remove the `nixos` channel for both users
      # and root e.g. `nix-channel --remove nixos`. `nix-channel
      # --list` should be empty for all users afterwards
      nixPath = [ "nixpkgs=${nixpkgs}" ];

      settings = {
        # use custom binary cache
        trusted-public-keys = mkIf (cfg.disable-cache != true)
          [ "cache.lounge.rocks:uXa8UuAEQoKFtU8Om/hq6d7U+HgcrduTVr8Cfl6JuaY=" ];
        substituters = mkIf (cfg.disable-cache != true) [
          "https://cache.nixos.org"
          "https://cache.lounge.rocks?priority=100"
        ];
        trusted-substituters = mkIf (cfg.disable-cache != true) [
          "https://cache.nixos.org"
          "https://cache.lounge.rocks"
        ];
        # Save space by hardlinking store files
        auto-optimise-store = true;
      };

      # Clean up old generations after 30 days
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      extraOptions = ''
        # this enables the technically experimental feature Flakes
        experimental-features = nix-command flakes

        # If set to true, Nix will fall back to building from source if a binary substitute fails.
        fallback = true

        # the timeout (in seconds) for establishing connections in the binary cache substituter. 
        connect-timeout = 10

        # these log lines are only shown on a failed build
        log-lines = 25
      '';
    };

    nixpkgs = {
      # Allow unfree licenced packages
      config.allowUnfree = true;
      overlays = [ flake-self.overlays.default ];
    };

    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.05"; # Did you read the comment?

  };
}
