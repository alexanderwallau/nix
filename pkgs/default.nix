{ pkgs ? import <nixpkgs> { } }: {
  # left for future reference
  todoist-electron = pkgs.callPackage ./todoist-electron { };
  logseq = pkgs.callPackage ./logseq { };
}
