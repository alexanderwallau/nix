{ pkgs ? import <nixpkgs> { } }: {
  # left for future reference
  mtu-check = pkgs.callPackage ./mtu-check { };
  frizbox-exporter = pkgs.callPackage ./frizbox-exporter { };
}
