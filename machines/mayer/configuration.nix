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
      ./static-sites.nix
      ./wg0.nix
    ];

  services.qemuGuest.enable = true;
  # top level option name
  # by using awallau.* for all our modules, we won't have any conflicts with other modules
  awallau = {
    anki-sync = {
      enable = true;
      User = "awallau";
      passwordFile = "/var/src/secret/anki-sync";
      domain = "anki-sync.alexanderwallau.de";
    };
    audiobookshelf = {
      enable = true;
      port = 13378;
      domain = "audiobookshelf.alexanderwallau.de";
    };
    containers =
      {
        rss-bridge = {
          enable = true;
          domain = "rss-bridge.alexanderwallau.de";
          port = "3134";
        };
      };
      cryptpad = {
        enable = true;
        domain = "cryptpad.alexanderwallau.de";
        httpSafeOrigin = "cryptpad-sb.alexanderwallau.de";
        port = 3002;
        websocketPort = 3003;
        #adminKeys = [ "[
      };
    docker.enable = true;
    # enable freshrss
    freshrss = {
      enable = true;
      defaultUser = "awallau";
      passwordFile = "/var/src/secret/freshrss";
      passwordFilePostgres = "/var/src/secret/freshrss-postgres";
      domain = "rss.alexanderwallau.de";
    };
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
    metrics = { node = { enable = true; flake = true; }; };
    nginx.enable = true;
    # set up general nix stuff
    nix-common.enable = true;
    onlyoffice = {
      enable = true;
      domain = "onlyoffice.alexanderwallau.de";
    };
    # set up language and timezone
    locales.enable = true;
    # set up paperless
    paperless.enable = true;
    # set up ssh server
    openssh.enable = true;
    
    postgres = {
      enable = true;
      port = 5432;
    };
    # recepies
    tandoor = {
      enable = false;
      domain = "rezepte.alexanderwallau.de";
    };

    # enables users which got moved into a seperate file
    user = {
      awallau.enable = true;
      root.enable = true;
    };
    # zsh as default shell for all users
    zsh.enable = true;
  };

  # Build arm images
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # lol

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

    firewall = { 
      allowedTCPPorts = [ 443 80 9100 9115 ]; 
      trustedInterfaces = ["wg0" ];
      };
    nameservers = [ "192.168.69.1" "1.1.1.1" ];

    # Fallback ntp service, this one being T-Online
    timeServers = [
      "ptbtime1.ptb.de"
      "ptbtime2.ptb.de"
      "ptbtime3.ptb.de"
    ];
    
    hostName = "mayer";
  };




}
