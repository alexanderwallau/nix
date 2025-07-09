{ config, pkgs, lib, ... }: {

  # Install these packages for my user
  home.packages =
    with pkgs; [

      # packages from nixpkgs
      bonn-mensa
      cifs-utils
      cmake
      cups
      dconf
      discord
      dnsutils
      element-desktop
      eza
      firefox
      ffmpeg
      fuse3
      gcc
      gdu
      gimp
      gitui
      gparted
      gping
      gthumb
      inkscape
      iperf3
      julia
      libreoffice
      libsForQt5.kio-gdrive
      mullvad-vpn
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
      qemu
      restic
      signal-desktop
      spotify
      tdesktop
      thunderbird-bin
      tidal-dl
      qobuz-dl
      #lyricsgenius
      unzip
      vlc
      wireguard-go
      xournalpp
      kdePackages.yakuake
      yubioath-flutter
      zip
    ];

  awallau.programs = {
    direnv.enable = true;
    foot.enable = true;
    git.enable = true;
    htop.enable = true;
    python.enable = true;
    tmux.enable = true;
    vim.enable = false;
    vscode.enable = true;
    zsh.enable = true;

  };

  # Imports
  imports = [
    ../colorscheme.nix
    ../modules/direnv
    ../modules/foot
    ../modules/git
    ../modules/nvim
    ../modules/python
    ../modules/vscode
    ../modules/zsh
    ../modules/htop
    ../modules/sway
    ../modules/swaylock
    ../modules/waybar
    ../modules/tmux
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
