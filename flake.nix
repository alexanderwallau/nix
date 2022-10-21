{
  description = "A very basic flake";

  inputs = {
    # https://github.com/nixos/nixpkgs
    # nixos repository
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # https://github.com/nix-community/home-manager
    # manage a user environment using Nix
    home-manager.url = "github:nix-community/home-manager";

    # https://github.com/nixos/nixos-hardware
    # hardware specific configuration for NixOS
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # https://github.com/numtide/flake-utils
    # flake-utils provides a set of utility functions for creating multi-output flakes
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, ... }@inputs:
    with inputs;
    {


      # Output all modules in ./modules to flake. Modules should be in
      # individual subdirectories and contain a default.nix file
      nixosModules = builtins.listToAttrs
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

            system = "x86_64-linux";

            modules = [
              (./machines + "/${x}/configuration.nix")
              # import our own modules to all hosts
              { imports = builtins.attrValues self.nixosModules; }
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

      });
}
