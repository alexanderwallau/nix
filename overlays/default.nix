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

}
