{ pkgs, config, ... }:

{
  imports = [
    ./exporter/node.nix

    ./grafana.nix
    ./prometheus.nix
  ];
}
