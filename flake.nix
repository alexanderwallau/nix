{
  description = "A very basic flake";

  inputs = {
    # https://github.com/nixos/nixpkgs
    # nixos repository
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";


    # Modular flake attributes
    # https://github.com/hercules-ci/flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";

    # Manage networks of machines
    # https://clan.lol
    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
    clan-core.inputs.nixpkgs.follows = "nixpkgs";
    clan-core.inputs.flake-parts.follows = "flake-parts";

    # https://github.com/nix-community/home-manager
    # manage a user environment using Nix
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nixos/nixos-hardware
    # hardware specific configuration for NixOS
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # we are using the alexanderwallau-keys flake to get the ssh keys from github
    alexanderwallau-keys.url = "https://github.com/alexanderwallau.keys";
    alexanderwallau-keys.flake = false;

    # Adblocking lists for Unbound DNS servers running on NixOS
    # https://github.com/MayNiklas/nixos-adblock-unbound
    adblock-unbound = {
      url = "github:MayNiklas/nixos-adblock-unbound";
      inputs = {
        adblockStevenBlack.follows = "adblockStevenBlack";
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
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    plasma-manager = {
      # KDE Plasma User Settings Generator
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "nixpkgs";
    };
    argononed = {
      url = "gitlab:DarkElvenAngel/argononed/master";
      flake = false;
    };


    bonn-mensa = {
      url = "github:alexanderwallau/bonn-mensa";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };

    # https://github.com/musnix/musnix/
    # A collection of optimization options for realtime audio
    musnix.url = "github:musnix/musnix";

    # An openmensa compatible parser for the Bonner Studierendenwerk
    stwb-openmensa.url = "github:alexanderwallau/stwb-openmensa";
    

  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({lib, withSystem, ...}:{
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      imports = [
          #inputs.clan-core.flakeModules.default
          #inputs.home-manager.flakeModules.home-manager
          inputs.pkgs-by-name-for-flake-parts.flakeModule
          # Each <name>.flake.nix is a flake-parts module
          #(inputs.import-tree (i: i.initFilter (lib.hasSuffix ".flake.nix")) ./modules)
        ];
        flake.overlays.default =
          final: prev:
          withSystem prev.stdenv.hostPlatform.system (
            { config, ... }:
            {
              awallau = config.packages;
            }
          );

      perSystem = { system, pkgs, ... }:
        {
          # Use nixpkgs-fmt for `nix fmt`.
          formatter = pkgs.nixpkgs-fmt;
          # Each ./pkgs/<name>/package.nix becomes .#packages.<system>.<name>
          pkgsDirectory = ./pkgs;
        };

        # Output all modules in ./modules to flake. Modules should be in
        # individual subdirectories and contain a default.nix file.
        flake.nixosModules =
          builtins.listToAttrs
            (map
              (x: {
                name = x;
                value = import (./modules + "/${x}");
              })
              (builtins.attrNames (builtins.readDir ./modules)))
          // {
            user = { ... }: {
              imports = [ ./user ];
            };
            home-manager = { ... }: {
              imports = [
                ./home-manager
                inputs.home-manager.nixosModules.home-manager
              ];
            };
          };

        # Each subdirectory in ./machines is a host. Add them all to
        # nixosConfigurations. Host configurations need a file called
        # configuration.nix that will be read first.
        flake.nixosConfigurations = builtins.listToAttrs (map
          (x: {
            name = x;
            value = nixpkgs.lib.nixosSystem {
              # Make inputs and the flake itself accessible as module parameters.
              specialArgs = { flake-self = self; } // inputs;

              modules = builtins.attrValues self.nixosModules ++ [
                (import "${./.}/machines/${x}/configuration.nix" { inherit self; })
                inputs.disko.nixosModules.disko
                inputs.vscode-server.nixosModules.default
                inputs.sops-nix.nixosModules.sops
                {
                  services.vscode-server.enable = true;
                }
              ];
            };
          })
          (builtins.attrNames (builtins.readDir ./machines)));
    });
}
