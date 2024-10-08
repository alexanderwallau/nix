# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, ... }:
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
    metrics = { node = { enable = true; flake = true; }; };
    # set up general nix stuff
    nix-common.enable = true;
    # set up language and timezone    
    locales.enable = true;
    #logitech special functions for MX Master 3S
    #surrently broken
    #logiops.enable = true;
    # DNS server on localhost
    unbound.enable = true;
    # set up ssh server
    openssh.enable = true;
    # priniting
    printing.enable = true;
    # enables users which got moved into a seperate file
    user = {
      awallau.enable = true;
      root.mayniklas = true;
    };
    yubikey.enable = true;
    # Need Bluetooth
    bluetooth.enable = true;
    # Sound maybe
    sound.enable = true;
    # zsh as default shell for all users
    zsh.enable = true;
  };

  # install packages system wide
  environment.systemPackages = with pkgs;
    [
      _1password-gui
      bolt
      fprintd
      musescore
      plasma5Packages.plasma-thunderbolt
      texlive.combined.scheme-full
      virt-manager
      zoom-us
    ];
  # Virtualisation
  virtualisation = {
    libvirtd = {
      enable = true;
    };
    vmware.host = {
      enable = true;
    };
  };

  # Onedrive
  services.onedrive.enable = true;

  # Steam
  programs.steam = { enable = true; };
  #build arm64 packages
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Because Lenovo Thermal design choices
  # services.throttled.enable = true;

  # Define hostname.
  networking = {
    hostName = "X1-Yoga";
    # Monitoring
    firewall.interfaces."Kipchoge".allowedTCPPorts = [ 9100 ];
    # Fallback ntp service, this one being T-Online
    timeServers = [
      "ptbtime1.ptb.de"
      "ptbtime2.ptb.de"
      "ptbtime3.ptb.de"
    ];

  };
}

