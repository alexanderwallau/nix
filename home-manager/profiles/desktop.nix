{ config, pkgs, lib, ... }: {

  # Install these packages for my user
  home.packages =
    with pkgs; [
      _1password-gui
      dconf
      discord
      element-desktop
      firefox
      fuse3
      gcc
      glances
      gparted
      htop
      iperf3
      libreoffice
      libwebcam
      nerdfonts
      nixpkgs-fmt
      nmap
      obs-studio
      pipewire
      signal-desktop
      spotify
      steam
      tdesktop
      texlive.combined.scheme-full
      thunderbird-bin
      unzip
      vlc
      wireguard-tools
      yakuake
      zoom-us
    ];

  awallau.programs = {
    git.enable = true;
    python.enable = true;
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

  services.gnome-keyring = { enable = true; };

  # Include man-pages
  manual.manpages.enable = true;

  # tells you the package that provides a command
  programs.command-not-found.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow "unfree" licenced packages
  nixpkgs.config = { allowUnfree = true; };

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
