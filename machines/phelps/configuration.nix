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
      ./wg0.nix
    ];

  # top level option name
  # by using awallau.* for all our modules, we won't have any conflicts with other modules
  awallau = {
    containers = {
      dashy = {
        enable = true;
        configFile = "/var/lib/dashy/conf.yml";
        domain = "fsdash.awll.de";
        port = "3132";
      };
    };
    docker.enable = true;
    #gitlab runner 1
    gitlab-runner = {
      enable = true;
      dockerImage = "ubuntu:23.10";
      registrationConfigFile = "/var/lib/gitlab-runner/config-1";
    };

    # enable home-manager profile
    home-manager = { enable = true; profile = "server"; };
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
    uptime-kuma = {
      enable = true;
      domain = "status.ubo.awll.de";
    };
    # zsh as default shell for all users
    zsh.enable = true;
  };


  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 443 80 ];
      trustedInterfaces = [ "wg0" ];
    };
    nameservers = [ "192.168.69.1" "1.1.1.1" ];
    timeServers = [
      "ptbtime1.ptb.de"
      "ptbtime2.ptb.de"
      "ptbtime3.ptb.de"
    ];
    hostName = "phelps";
  };
}
