# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# Since this is the only Hetzner-x86 machine a dedicated cloud module did not seem nessesary
{ self, ... }:
{ config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #./wg0.nix
    ];



  # top level option name
  # by using awallau.* for all our modules, we won't have any conflicts with other modules
  awallau = {
    docker.enable = true;
    # enable home-manager profile
    home-manager = { enable = true; profile = "server"; };
    # set up language and timezone
    locales.enable = true;

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
  # Build arm images
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  
  # Reduce Size
  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
  };


  networking = {
    enableIPv6 = true;
    dhcpcd.IPv6rs = true;
    interfaces."enp1s0" = {
      ipv6.addresses = [ { address = "2a01:4ff:f0:99e::1"; prefixLength = 64; } ];
    };
      defaultGateway6 = {
        address = "fe80::1";
        interface = "eth0";
      };
    firewall = {
      allowedTCPPorts = [ 443 80 9100];
      #trustedInterfaces = [ "wg0" ];
    };

    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    # Fallback ntp service, this one being not T-Online since us east coast xDD
    timeServers = [
      "0.us.pool.ntp.org"
      "1.us.pool.ntp.org"
      "2.us.pool.ntp.org"
    ];
    hostName = "werth";
  };
}
