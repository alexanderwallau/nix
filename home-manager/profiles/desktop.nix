{ config, pkgs, lib, ... }: {

  # Install these packages for my user
  home.packages =
    with pkgs; [
      # my packages
      #awallau.musescore

      # packages from nixpkgs
      _1password-gui
      bolt
      bonn-mensa
      cifs-utils
      cmake
      cups
      dconf
      discord
      dnsutils
      dogdns
      element-desktop
      eza
      firefox
      fuse3
      gcc
      gdu
      gimp
      gitui
      glances
      gparted
      gping
      hcloud
      hue-cli
      inkscape
      iperf3
      ipu6ep-camera-bin
      jetbrains.pycharm-professional
      #jetbrains.clion
      julia
      libnfc
      libreoffice
      libwebcam
      libsForQt5.kio-gdrive
      minecraft
      musescore
      neofetch
      networkmanager-openvpn
      nextcloud-client
      nixpkgs-fmt
      nmap
      ntfs3g
      obs-studio
      obsidian
      owncloud-client
      p7zip
      pciutils
      pipewire
      plasma5Packages.plasma-thunderbolt
      protonvpn-gui
      qemu
      qrencode
      restic
      rnote
      signal-desktop
      spotify
      tdesktop
      texlive.combined.scheme-full
      thunderbird-bin
      tidal-dl
      #todoist-electron
      unzip
      virt-manager
      vlc
      wait-for-build
      wireguard-go
      wireguard-tools
      xournal
      yakuake
      yubioath-flutter
      zip
      zoom-us
    ];

  awallau.programs = {
    direnv.enable = true;
    foot.enable = true;
    git.enable = true;
    htop.enable = true;
    python.enable = true;
    #vim.enable = true;
    vscode.enable = true;
    zsh.enable = true;

  };

  # Imports
  imports = [
    ../colorscheme.nix
    ../modules/direnv
    ../modules/foot
    ../modules/git
    #../modules/nvim
    ../modules/python
    ../modules/vscode
    ../modules/zsh
    ../modules/htop
    ../modules/sway
    ../modules/swaylock
    ../modules/waybar
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
    permittedInsecurePackages = [
      "electron-25.9.0"
    ];
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
