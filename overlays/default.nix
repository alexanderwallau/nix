inputs:
let
  # Pass flake inputs to overlay so we can use the sources pinned in flake.lock
  # instead of having to keep sha256 hashes in each package for src
  inherit inputs;
in
self: super: {
  # use own flake packages as overlay for nixpkgs

 
  # packages to get from nixpkgs-unstable
  musescore = self.unstable.musescore;
  obsidian = self.unstable.obsidian;
  spotify = self.unstable.spotify;
  todoist-electron = self.unstable.todoist-electron;
  vscode = self.unstable.vscode;
  yubioath-flutter = self.unstable.yubioath-flutter;
  
}
