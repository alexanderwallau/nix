# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, ... }:
{ config, pkgs, lib, shelly-exporter, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./wg0.nix
      ./wg1.nix
      ./unbound.nix

      shelly-exporter.nixosModules.default
    ];



  # top level option name
  # by using awallau.* for all our modules, we won't have any conflicts with other modules
  awallau = {
    docker.enable = true;
    # enable home-manager profile
    home-manager = { enable = true; profile = "server"; };
    # speedtesting to main cloud router
    #librespeed = {
    #  enable = true;
    #  title = "Connection Speed";
    #};
    # set up language and timezone    
    locales.enable = true;
    # minio for s3
    minio = {
      enable = true;
      domain = "s3.alexanderwallau.de";
    };
    metrics = {
      node = {
        enable = true;
        flake = true;
        configure-prometheus = true;
        targets = [
          "kipchoge:9100"
          "x1-yoga:9100"

          "192.168.178.3:9100"
          "192.168.178.4:9100"
          "192.168.178.9:9100"
        ];
      };
      blackbox = {
        enable = true;
        configure-prometheus = true;
        blackboxPingTargets = [
          "192.168.178.1"
        ];
        targets = [
          "https://cache.lounge.rocks/nix-cache/nix-cache-info"
          "https://build.lounge.rocks"
          "https://git.alexanderwallau.de"
        ];
      };
    };
    monitoring = {
      grafana = {
        enable = true;
        nginx = true;
      };
      prometheus.enable = true;
    };
    netbox = {
      enable = true;
      domain = "netbox.alexanderwallau.de";
    };
    nginx.enable = true;
    # set up general nix stuff
    nix-common.enable = true;
    # set up ssh server
    openssh.enable = true;
    # enables users which got moved into a seperate file
    podman.enable = true;
    uptime-kuma = {
      domain = "uptime.alexanderwallau.de";
      enable = true;
    };
    user = {
      awallau.enable = true;
      root.enable = true;
    };
    # zsh as default shell for all users
    zsh.enable = true;
  };

  services.shelly-exporter = {
    enable = true;
    port = "8080";
    listen = "localhost";
    user = "shelly-exporter";
    group = "shelly-exporter";

    configure-prometheus = true;

    targets = [
      "http://192.168.178.70"
      "http://192.168.178.71"
      "http://192.168.178.75"
      "http://192.168.178.76"
    ];
  };

  # install packages system wide
  environment.systemPackages = with pkgs;
    [
      bash-completion
      wget
      git
    ];
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.hostName = "kipchoge";
}

