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
    # enable home-manager profile
    home-manager = { enable = true; profile = "server"; };
    # set up general nix stuff
    nix-common.enable = true;
    # set up language and timezone    
    locales.enable = true;
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

  networking.hostName = "phelps";
}
