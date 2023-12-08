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
  services.qemuGuest.enable = true;
  # top level option name
  # by using awallau.* for all our modules, we won't have any conflicts with other modules
  awallau = {
    #enable gitea
    gitea.enable = true;
    # enable hedgedoc
    hedgedoc = {
      enable = true;
      domain = "md.alexanderwallau.de";
    };
    # enable home-manager profile
    home-manager = {
      enable = true;
      profile = "server";
    };
    # set up general nix stuff
    nix-common.enable = true;
    # set up language and timezone    
    locales.enable = true;
    # set up paperless
    paperless.enable = true;
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

  # install packages system wide
  environment.systemPackages = with pkgs;
    [
      bash-completion
      wget
      git
    ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "mail@alexanderwallau.de";
  };

  networking = {
    enableIPv6 = true;
    dhcpcd.IPv6rs = true;
    interfaces.ens3 = {
      ipv6.addresses = [{ address = "2a0a:4cc0:1:73::1"; prefixLength = 64; }];
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
    firewall = { allowedTCPPorts = [ 443 80 9100 9115 ]; };

    hostName = "mayer";
  };




}

