# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # top level option name
  # by using awallau.* for all our modules, we won't have any conflicts with other modules
  awallau = {
    # enables the docker module
    docker.enable = true;
    # enable home-manager profile
    home-manager.enable = true;
    # enable kde & xserver
    kde.enable = true;
    # set up general nix stuff
    nix-common.enable = true;
    # set up language and timezone    
    locales.enable = true;
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
  };

  # install packages system wide
  environment.systemPackages = with pkgs;
    [
      bash-completion
      fprintd
      wget
      git
    ];

  nixpkgs.config.permittedInsecurePackages = [
                "electron-21.4.0"
              ];
    


  # Define hostname.
  networking.hostName = "X1-Yoga";
}

