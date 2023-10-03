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
    #docker.enable = true;
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
    #unbound.enable = true;
    # set up ssh server
    openssh.enable = true;
    # enables users which got moved into a seperate file
    user = {
      awallau.enable = true;
      root.enable = true;
    };
    #yubikey.enable = true;
    # Need Bluetooth
    #bluetooth.enable = true;
    # Sound maybe
    sound.enable = true;
    # zsh as default shell for all users
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
  # Virtualisation
  #virtualisation.libvirtd.enable = true;
  #Printing 
  #services.printing.enable = true;
  #services.avahi.enable = true;
  #services.avahi.nssmdns = true;
  # for a WiFi printer
  #services.avahi.openFirewall = true;
  #services.printing.drivers = [ pkgs.hplipWithPlugin ];
  # Onedrive
  #services.onedrive.enable = true;

  # Steam
  #build arm64 packages
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Define hostname.
  networking.hostName = "fischer";
}

