# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, ... }:
{ pkgs, lib, config, modulesPath, flake-self, home-manager, nixos-hardware, nixpkgs, ... }: {

  imports = [
    # being able to build the sd-image
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ./hardware-config.nix
    ./wg0.nix
  ];

  ### build sd-image
  # nix build .\#nixosConfigurations.pi4b.config.system.build.sdImage
  sdImage.compressImage = false;
  sdImage.imageBaseName = "pi4b-image";
  # currently needed to build the sd-image - will need to be removed in the future
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
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

  # Enable argonone fan daemon
  # Now in nixpkgs.unstable
  # The default package suffises
  services.hardware.argonone.enable = true;
  # Small Role upgrade for the pi
  services.unifi = {
    enable = true;
    openFirewall = true;
    unifiPackage = pkgs.unifi;
    mongodbPackage = pkgs.mongodb-6_0;

  };

  environment.systemPackages = with pkgs;
    [
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
# In theory a good Idea, not that good when using this thing on the go so for now disable this
#    defaultGateway = "192.168.178.1";
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
