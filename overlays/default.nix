inputs:
let
  # Pass flake inputs to overlay so we can use the sources pinned in flake.lock
  # instead of having to keep sha256 hashes in each package for src
  inherit inputs;
in
self: super: {
  # use own flake packages as overlay for nixpkgs
  vs-fix = super.pkgs.callPackage ../pkgs/vs-fix { };
  fritzbox-exporter = super.callPackage ../pkgs/fritzbox-exporter { };
  mtu = super.callPackage ../pkgs/mtu { };
}
