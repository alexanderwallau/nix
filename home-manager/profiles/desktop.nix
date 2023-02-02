{ config, pkgs, lib, ... }: {

  # Install these packages for my user
  home.packages =
    with pkgs; [
      # my packages
      awallau.musescore

      # packages from nixpkgs
      _1password-gui
      amdvlk
      bolt
      dconf
      discord
      element-desktop
      firefox
      gimp
      inkscape
      libnfc
      libreoffice
      libwebcam
      minecraft
      nerdfonts
      nextcloud-client
      obs-studio
      obsidian
      plasma5Packages.plasma-thunderbolt
      protonvpn-gui
      signal-desktop
      spotify
      tdesktop
      texlive.combined.scheme-full
      thunderbird-bin
      todoist-electron
      vlc
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
