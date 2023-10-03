{ pkgs, config, ... }:

{
  imports = [
    ./grafana.nix
    ./prometheus.nix
  ];
}
