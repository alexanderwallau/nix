# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, ... }:
{ config, pkgs,nixos-hardware, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-x220
  ];

  # top level option name
  # by using awallau.* for all our modules, we won't have any conflicts with other modules
  awallau = {
    # enables the docker module
    docker.enable = true;
    # enable home-manager profile
    home-manager.enable = true;
    # enable kde & xserver
    #kde.enable = true;
    # set up general nix stuff
    nix-common.enable = true;
    #logitech special functions for MX Master 3S
    #surrently broken
    #logiops.enable = true;
    # DNS server on localhost
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
    sway.enable = true;
    zsh.enable = true;
  };

  # install packages system wide
  environment.systemPackages = with pkgs;
    [
      bash-completion
      fprintd
      wget
      git
      virt-manager
    ];
  # sway on tty1 login
  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && sway
  '';
  # Virtualisation
  virtualisation.libvirtd.enable = true;
  # fingerprint login
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
    sound.mediaKeys.enable = true;

  # automatic screen orientation
  hardware.sensor.iio.enable = true;
    services.illum.enable = true;

  # Define hostname.
  networking= {
    hostName = "fischer";
    networkmanager.enable = true;
  };
}

