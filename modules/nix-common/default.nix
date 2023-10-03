{ lib, pkgs, config, nixpkgs, flake-self, nixpkgs-unstable, ... }:
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
        trusted-public-keys = mkIf (cfg.disable-cache != true) [
          "nix-cache:4FILs79Adxn/798F8qk2PC1U8HaTlaPqptwNJrXNA1g="
          "alexanderwallau.cachix.org-1:vi7QC6uUBbRi69tJmp/Ylta1f3BliiW2ABV89EFRiX0="
          "mayniklas.cachix.org-1:gti3flcBaUNMoDN2nWCOPzCi2P68B5JbA/4jhUqHAFU="
        ];
        substituters = mkIf (cfg.disable-cache != true) [
          "https://cache.nixos.org"
          "https://alexanderwallau.cachix.org?priority=75"
          "https://mayniklas.cachix.org?priority=75"
          "https://cache.lounge.rocks/nix-cache?priority=100"
        ];
        trusted-substituters = mkIf (cfg.disable-cache != true) [
          "https://cache.nixos.org"
          "https://cache.lounge.rocks"
        ];
        # Save space by hardlinking store files
        auto-optimise-store = true;
      };

      # Clean up old generations after 14 days
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
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
      overlays = [
        flake-self.overlays.default
        (final: prev: {
          unstable = import nixpkgs-unstable {
            system = "${pkgs.system}";
            config.allowUnfree = true;
          };
        })
      ];
    };

    # Let 'nixos-version --json' know the Git revision of this flake.
    system.configurationRevision = nixpkgs.lib.mkIf (flake-self ? rev) flake-self.rev;
    nix.registry.nixpkgs.flake = nixpkgs;

    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.05"; # Did you read the comment?

  };
}
