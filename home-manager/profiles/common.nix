{ config, pkgs, lib, ... }: {

  # Install these packages for my user
  home.packages =
    with pkgs; [

      # packages from nixpkgs
      fuse3
      gcc
      glances
      gparted
      htop
      iperf3
      julia
      neofetch
      networkmanager-openvpn
      nixpkgs-fmt
      nmap
      ntfs3g
      pciutils
      pipewire
      qemu
      rgp
      unzip
      wireguard-go
      wireguard-tools

    ];

  awallau.programs = {
    git.enable = true;
    python.enable = false;
    vim.enable = true;
    vscode.enable = true;
    zsh.enable = true;

  };

  # Imports
  imports = [
    ../modules/git
    ../modules/nvim
    ../modules/python
    ../modules/vscode
    ../modules/zsh
  ];
  fonts.fontconfig.enable = true;
  services.gnome-keyring = { enable = true; };

  # Include man-pages
  manual.manpages.enable = true;

  # tells you the package that provides a command
  programs.command-not-found.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow "unfree" licenced packages
  nixpkgs.config = {
    allowUnfree = true;
  };
}