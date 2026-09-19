# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./disko.nix # Disk config
      # ./wg0.nix only on second boot, when keys have been established

    ];

  # top level option name
  # by using awallau.* for all our modules, we won't have any conflicts with other modules
  awallau = {
    docker.enable = true;
    # enable home-manager profile
    home-manager = { enable = true; profile = "server"; };
    # set up language and timezone
    locales.enable = true;
    # enable note exporter
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

    # Reduce Size of image
  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
  };

  
  networking = {
    enableIPv6 = true;
    dhcpcd.IPv6rs = true;
    interfaces.eth0 = {
      ipv6.addresses = [{ address = "2a03:4000:2a:46e:185e:aff:fe0e:a3a2"; prefixLength = 64; }];
    };

    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };

    firewall = { 
      allowedTCPPorts = [ 80 443 ]; 
      # Means wg0 is completly open which in this case is fine 
      #trustedInterfaces = ["wg0" ];
      };
    nameservers = [ "192.168.69.1" "1.1.1.1" ];

    # Fallback ntp service, this one not being T-Online but the 
    # Physikalisch-Technische Bundesanstalt
    timeServers = [
      "ptbtime1.ptb.de"
      "ptbtime2.ptb.de"
      "ptbtime3.ptb.de"
    ];
    
    hostName = "hase";
  };
}