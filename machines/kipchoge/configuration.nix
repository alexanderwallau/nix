# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, ... }:
{ config, pkgs, shelly-exporter, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./wg0.nix

      shelly-exporter.nixosModules.default
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
    metrics = {
      node = {
        enable = true;
        flake = true;
        configure-prometheus = true;
        targets = [
          "192.168.69.1:9100"
          "192.168.69.100:9100"
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
    nginx.enable = true;
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

  services.shelly-exporter = {
    enable = true;
    port = "8080";
    listen = "localhost";
    user = "shelly-exporter";
    group = "shelly-exporter";

    configure-prometheus = true;

    targets = [
      "http://192.168.0.2"
      "http://192.168.0.3"
      "http://192.168.0.4"
      "http://192.168.0.5"
      "http://192.168.0.6"
      "http://192.168.0.7"
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

