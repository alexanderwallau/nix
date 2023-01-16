{ pkgs ? import <nixpkgs> { } }: {
  musescore = pkgs.libsForQt5.callPackage ./musescore { };
}
