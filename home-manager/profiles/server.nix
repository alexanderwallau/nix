{ config, pkgs, lib, ... }: {

  # Install these packages for my user
  home.packages =
    let
      vs-fix = pkgs.callPackage ../../pkgs/vs-fix { };
    in
    with pkgs; [
      # packages from nixpkgs
      cifs-utils
      cmake
      dconf
      dnsutils
      dogdns
      eza
      fuse3
      gdu
      gping
      neofetch
      nixpkgs-fmt
      nmap
      unzip
      zip

      vs-fix
    ];

  awallau.programs = {
    git.enable = true;
    htop.enable = true;
    vim.enable = true;
    zsh.enable = true;
    python.enable = false;

  };

  # Imports
  imports = [
    ../modules/git
    ../modules/nvim
    ../modules/zsh
    ../modules/htop
    ../modules/python
  ];



  # Include man-pages
  manual.manpages.enable = true;

  # tells you the package that provides a command
  programs.command-not-found.enable = false;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow "unfree" licenced packages
  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";
}
