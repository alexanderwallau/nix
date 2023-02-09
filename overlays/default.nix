inputs:
let
  # Pass flake inputs to overlay so we can use the sources pinned in flake.lock
  # instead of having to keep sha256 hashes in each package for src
  inherit inputs;
in
self: super: {
  # use own flake packages as overlay for nixpkgs
  awallau.musescore = self.musescore;

  # packages to get from nixpkgs-unstable
  obsidian = self.unstable.obsidian;
  todoist-electron = self.unstable.todoist-electron;
  yubioath-flutter = self.unstable.yubioath-flutter;
  spotify = self.unstable.spotify;
}
