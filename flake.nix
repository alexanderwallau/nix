{
  description = "A very basic flake";

  inputs = {
    # https://github.com/nixos/nixpkgs
    # nixos repository
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # https://github.com/numtide/flake-utils
    # flake-utils provides a set of utility functions for creating multi-output flakes
    flake-utils.url = "github:numtide/flake-utils";

    # https://github.com/nix-community/home-manager
    # manage a user environment using Nix
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    # https://github.com/nixos/nixos-hardware
    # hardware specific configuration for NixOS
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # lollypops deployment tool
    # https://github.com/pinpox/lollypops
    lollypops = {
      url = "github:pinpox/lollypops";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    # we are using the alexanderwallau-keys flake to get the ssh keys from github
    alexanderwallau-keys.url = "https://github.com/alexanderwallau.keys";
    alexanderwallau-keys.flake = false;

    # Adblocking lists for Unbound DNS servers running on NixOS
    # https://github.com/MayNiklas/nixos-adblock-unbound
    adblock-unbound = {
      url = "github:MayNiklas/nixos-adblock-unbound";
      inputs = {
        adblockStevenBlack.follows = "adblockStevenBlack";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    # Adblocking lists for DNS servers
    # input here, so it will get updated by nix flake update
    adblockStevenBlack = {
      url = "github:StevenBlack/hosts";
      flake = false;
    };


    shelly-exporter = {
      url = "github:MayNiklas/shelly-exporter";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
    };

  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    with inputs;
    {

      # Expose overlay to flake outputs, to allow using it from other flakes.
      # Flake inputs are passed to the overlay so that the packages defined in
      # it can use the sources pinned in flake.lock
      overlays = {
        default = final: prev: (import ./overlays inputs) final prev;
      };

      packages = forAllSystems (system:
        import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; }
      );

      # Output all modules in ./modules to flake. Modules should be in
      # individual subdirectories and contain a default.nix file
      nixosModules =
        builtins.listToAttrs
          (map
            (x: {
              name = x;
              value = import (./modules + "/${x}");
            })
            (builtins.attrNames (builtins.readDir ./modules)))

        //
        {
          user = { config, pkgs, lib, ... }: {
            imports = [ ./user ];
          };
        }
        //
        {
          home-manager = { config, pkgs, lib, ... }: {
            imports = [
              ./home-manager
              home-manager.nixosModules.home-manager
            ];
          };
        };

      # Each subdirectory in ./machines is a host. Add them all to
      # nixosConfiguratons. Host configurations need a file called
      # configuration.nix that will be read first
      nixosConfigurations = builtins.listToAttrs (map
        (x: {
          name = x;
          value = nixpkgs.lib.nixosSystem {

            # Make inputs and the flake itself accessible as module parameters.
            # Technically, adding the inputs is redundant as they can be also
            # accessed with flake-self.inputs.X, but adding them individually
            # allows to only pass what is needed to each module.
            specialArgs = { flake-self = self; } // inputs;

            modules = builtins.attrValues self.nixosModules ++ [
              lollypops.nixosModules.lollypops
              (import "${./.}/machines/${x}/configuration.nix" { inherit self; })
            ];

          };
        })
        (builtins.attrNames (builtins.readDir ./machines)));

    }

    //

    # this function is used to repeat the same definitions for multible architectures
    (flake-utils.lib.eachSystem (flake-utils.lib.defaultSystems)) (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnsupportedSystem = true;
            allowUnfree = true;
          };
        };
      in
      rec {

        # Use nixpkgs-fmt for `nix fmt'
        formatter = pkgs.nixpkgs-fmt;

        packages = {
          woodpecker-pipeline = pkgs.callPackage ./pkgs/woodpecker-pipeline { inputs = inputs; flake-self = self; };
        };

        apps = {
          # lollypops deployment tool
          # https://github.com/pinpox/lollypops
          #flake.nix
          # nix run '.#lollypops' -- --list-all
          # nix run '.#lollypops' -- phelps
          # nix run '.#lollypops' -- phelps X1-Yoga
          # nix run '.#lollypops' -- phelps X1-Yoga -p
          # nix run '.#lollypops' -- mayerX1-Yoga -p 
          default = self.apps.${pkgs.system}.lollypops;
          lollypops = lollypops.apps.${pkgs.system}.default {
            configFlake = self;
          };
        };

      });
}
