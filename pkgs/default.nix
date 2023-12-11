{ pkgs ? import <nixpkgs> { } }: {
  # left for future reference
  todoist-electron = pkgs.callPackage ./todoist-electron { };
  wait-for-build = pkgs.callPackage ./wait-for-build { };

  lyricsgenius = pkgs.callPackage ./lyricsgenius { inherit (pkgs) python3; };
  tidal-dl = pkgs.callPackage ./tidal-dl { inherit (pkgs) python3; inherit lyricsgenius; };

  frizbox-exporter = pkgs.callPackage ./frizbox-exporter { };
}
