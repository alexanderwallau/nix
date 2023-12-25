{ config, lib, pkgs, adblock-unbound, ... }:
with lib;
let
  adlist = adblock-unbound.packages.${pkgs.system};

  A-records = {
    "pass.telekom.de" = "109.237.176.33";
    "fritz.box" = "192.168.178.1";
    "nas.wallau" = "192.168.178.5";
    "iceportal.de" = "172.18.1.110";
    "status.alexanderwallau.de" = "192.168.69.1";
    "x1-yoga" = "192.168.69.100";

    "kipchoge.aw" = "192.168.69.1";
    "x1-yoga.aw" = "192.168.69.100";
    "mayer.aw" = "192.168.69.2";
    "phelps.aw" = "192.168.69.3";
  };

  dns-overwrites-config = builtins.toFile "dns-overwrites.conf" (''
    # DNS overwrites
  '' + concatStringsSep "\n"
    (mapAttrsToList (n: v: "local-data: \"${n} A ${toString v}\"") A-records));

in
{
  config = {

    networking.firewall.interfaces = {
      "wg0" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
      "wg1" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
    };

    services.unbound = {
      enable = true;
      settings = {

        server = {
          include = [
            "\"${dns-overwrites-config}\""
            "\"${adlist.unbound-adblockStevenBlack}\""
          ];
          interface = [
            "127.0.0.1"
            "192.168.69.1"
            "192.168.178.201"
          ];
          access-control = [
            "127.0.0.0/8 allow"
            "192.168.0.0/16 allow"
          ];
        };

        forward-zone = [
          {
            name = "fritz.box";
            forward-addr = [
              "192.168.178.1"
            ];
            forward-tls-upstream = "no";
          }
          {
            name = "nas.wallau";
            forward-addr = [
              "192.168.178.45"
            ];
            forward-tls-upstream = "no";
          }
          {
            name = "*.alexanderwallau.de";
            forward-addr = [
              "192.168.69.2"
            ];
            forward-tls-upstream = "yes";
          }
          {
            name = "*.s3.alexanderwallau.de";
            forward-addr = [
              "192.168.69.1"
            ];
            forward-tls-upstream = "yes";
          }
          {
            name = "google.*.";
            forward-addr = [
              "8.8.8.8@853#dns.google"
              "8.8.8.4@853#dns.google"
            ];
            forward-tls-upstream = "yes";
          }
          {
            name = ".";
            forward-addr = [
              "1.1.1.1@853#cloudflare-dns.com"
              "1.0.0.1@853#cloudflare-dns.com"
            ];
            forward-tls-upstream = "yes";
          }
        ];

      };
    };
  };

}
