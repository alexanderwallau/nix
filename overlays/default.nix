inputs:
let
  # Pass flake inputs to overlay so we can use the sources pinned in flake.lock
  # instead of having to keep sha256 hashes in each package for src
  inherit inputs;
in
self: super: {
  # use own flake packages as overlay for nixpkgs
  #todoist-electron = super.pkgs.callPackage ../pkgs/todoist-electron { };
  wait-for-build = super.pkgs.callPackage ../pkgs/wait-for-build { };

  # packages to get from nixpkgs-unstable
  #element-desktop = self.unstable.element-desktop;
  ipu6ep-camera-bin = self.unstable.ipu6ep-camera-bin;
  jetbrains.clion = self.unstable.jetbrains.clion;
  jetbrains.pycharm-professional = self.unstable.jetbrains.pycharm-professional;
  logseq = self.unstable.logseq;
  musescore = self.unstable.musescore;
  plex = self.unstable.plex;
  obsidian = self.unstable.obsidian;
  spotify = self.unstable.spotify;
  todoist-electron = self.unstable.todoist-electron;
  vscode = self.unstable.vscode;
  yubioath-flutter = self.unstable.yubioath-flutter;
  zotero = self.unstable.zotero;

}
