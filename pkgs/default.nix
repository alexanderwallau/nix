{ pkgs ? import <nixpkgs> { } }: {
  # left for future reference
  todoist-electron = pkgs.callPackage ./todoist-electron { };
  wait-for-build = pkgs.callPackage ./wait-for-build { };

  lyricsgenius = pkgs.callPackage ./lyricsgenius { inherit (pkgs) python3; };
  tidal-dl = pkgs.callPackage ./tidal-dl { inherit (pkgs) python3; inherit lyricsgenius; };
  qobuz-dl = pkgs.callPackage ./qobuz-dl { inherit (pkgs) python3; };
  mtu-check = pkgs.callPackage ./mtu-check { };

  frizbox-exporter = pkgs.callPackage ./frizbox-exporter { };
}
