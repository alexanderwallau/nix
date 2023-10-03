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

  lollypops.deployment.ssh = {
    user = "root";
    host = "s3.alexanderwallau.de";
  };

  # top level option name
  # by using awallau.* for all our modules, we won't have any conflicts with other modules
  awallau = {
    docker.enable = false;
    # enable home-manager profile
    home-manager = { enable = true; profile = "server"; };
    # set up general nix stuff
    nix-common.enable = true;
    # set up language and timezone    
    locales.enable = true;
    # minio for s3
    minio = {
      enable = true;
      domain = "s3.alexanderwallau.de";
    };
    # set up ssh server
    openssh.enable = true;
    # enables users which got moved into a seperate file
    user = {
      awallau.enable = true;
      root.enable = true;
      root.mayniklas = true;
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
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "mail@alexanderwallau.de";
  # Need TCP Ports 80 & 443 open for minio
  networking = { firewall = { allowedTCPPorts = [ 443 80 ]; }; };
  networking.hostName = "kipchoge";
}

