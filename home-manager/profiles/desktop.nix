{ config, pkgs, lib, ... }: {

  # Install these packages for my user
  home.packages =
    with pkgs; [
      # my packages
      #awallau.musescore

      # packages from nixpkgs
      _1password-gui
      amdvlk
      bolt
      cups
      dconf
      discord
      element-desktop
      firefox
      fuse3
      gcc
      gimp
      glances
      gparted
      htop
      hueadm
      inkscape
      iperf3
      julia
      libnfc
      libreoffice
      libwebcam
      minecraft
      musescore
      neofetch
      nerdfonts
      networkmanager-openvpn
      nextcloud-client
      nixpkgs-fmt
      nmap
      ntfs3g
      obs-studio
      obsidian
      pciutils
      pipewire
      plasma5Packages.plasma-thunderbolt
      protonvpn-gui
      qemu
      rgp
      signal-desktop
      spotify
      tdesktop
      texlive.combined.scheme-full
      thunderbird-bin
      todoist-electron
      unzip
      vlc
      wireguard-go
      wireguard-tools
      xournal
      yakuake
      yubioath-flutter
      zoom-us
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
