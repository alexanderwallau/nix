{ pkgs ? import <nixpkgs> { } }: {
  # left for future reference
  wait-for-build = pkgs.callPackage ./wait-for-build { };

  lyricsgenius = pkgs.callPackage ./lyricsgenius { inherit (pkgs) python3; };
  qobuz-dl = pkgs.callPackage ./qobuz-dl { inherit (pkgs) python3; };
  mtu-check = pkgs.callPackage ./mtu-check { };

  frizbox-exporter = pkgs.callPackage ./frizbox-exporter { };
}
