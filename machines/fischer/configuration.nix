# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, ... }:
{ config, pkgs, nixos-hardware, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # top level option name
  # by using awallau.* for all our modules, we won't have any conflicts with other modules
  awallau = {
    # enables the docker module
    docker.enable = true;
    gnome.enable = true;
    # enable home-manager profile
    home-manager.enable = true;
    # set up general nix stuff
    nix-common.enable = true;

    unbound.enable = true;
    # set up ssh server
    openssh.enable = true;
    # enables users which got moved into a seperate file
    user = {
      awallau.enable = true;
      root.enable = true;
    };
    yubikey.enable = true;
    # Need Bluetooth
    bluetooth.enable = true;
    # Sound maybe
    sound.enable = true;
    # zsh as default shell for all users
    # sway.enable = true;
    zsh.enable = true;
  };

  # install packages system wide
  environment.systemPackages = with pkgs;
    [
      bash-completion
      #fprintd
      wget
      git
      virt-manager
    ];

  # Virtualisation
  virtualisation.libvirtd.enable = true;

  # automatic screen orientation
  hardware.sensor.iio.enable = true;
  services.illum.enable = true;

  # Define hostname.
  networking = {
    hostName = "fischer";
    networkmanager.enable = true;
    timeServers = [
      "ptbtime1.ptb.de"
      "ptbtime2.ptb.de"
      "ptbtime3.ptb.de"
    ];

  };
}
