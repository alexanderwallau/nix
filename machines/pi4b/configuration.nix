# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, ... }:
{ pkgs, lib, config, modulesPath, flake-self, home-manager, argononed, nixos-hardware, nixpkgs, ... }: {
  imports = [
    # being able to build the sd-image
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ./hardware-config.nix
  ];

  # top level option name
  # by using awallau.* for all our modules, we won't have any conflicts with other modules
  awallau = {
    # enable home-manager profile
    home-manager = {
      enable = true;
      profile = "server";
    };
    # set up language and timezone
    locales.enable = true;
    # enable node exporter
    metrics = { node = { enable = true; flake = true; }; };
    # enable nginx
    nginx.enable = true;
    # set up general nix stuff
    nix-common.enable = true;
    # set up ssh server
    openssh.enable = true;
    # enables users which got moved into a seperate file
    user = {
      awallau.enable = true;
      root.enable = true;
    };
    # zsh as default shell for all users
    zsh.enable = true;
  };

  ### build sd-image
  # nix build .\#nixosConfigurations.pi4b.config.system.build.sdImage
  # add boot.binfmt.emulatedSystems = [ "aarch64-linux" ]; to your x86 system
  # to build ARM stuff through qemu
  sdImage.compressImage = false;
  sdImage.imageBaseName = "raspi-image";
  #  nix.registry.nixpkgs.flake = nixpkgs;
  #  nix.nixPath = [ "nixpkgs=${pkgs}" ];
  # this workaround is currently needed to build the sd-image
  # basically: there currently is an issue that prevents the sd-image to be built successfully
  # remove this once the issue is fixed!
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
  # Enable argonone fan daemon
  # services.hardware.argonone.enable = true;

  environment.systemPackages = with pkgs;
    [
      bash-completion
      wget
      git
      libraspberrypi
      raspberrypi-eeprom
    ];

  lollypops.deployment = {
    local-evaluation = true;
    ssh = { user = "root"; };
  };

  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
  };

  

  networking = {
    interfaces = {
      wlan0 = {
        useDHCP = true;
        wakeOnLan.enable = true;
      };
    };
    defaultGateway = "192.168.178.1";
    nameservers = [ "192.168.69.1" "1.0.0.1" ];
    networkmanager = {
      enable = true;
    };
    timeServers = [
      "ptbtime1.ptb.de"
      "ptbtime2.ptb.de"
      "ptbtime3.ptb.de"
    ];

    hostName = "pi4b";
  };

}
