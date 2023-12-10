{ pkgs, config, ... }:

{
  imports = [
    ./exporter/blackbox.nix
    ./exporter/nginx.nix
    ./exporter/node.nix
    ./exporter/wireguard.nix

    ./grafana.nix
    ./prometheus.nix
  ];
}
