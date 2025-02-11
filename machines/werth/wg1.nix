{ config, lib, pkgs, ... }: {
  sops.secrets ={
      "werth-wg1-private-key" = { };
    };
# US Exit vpn no other purpose
  networking = {
    firewall.allowedUDPPorts = [ 52193 ];
    wireguard.interfaces.wg1 = {

      ips = [ "192.168.70.1/24" ];
      listenPort = 52193;
      mtu = 1412;

      privateKeyFile = toString config.sops.secrets."werth-wg1-private-key".path;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 192.168.70.0/24 -o enp1s0 -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 192.168.70.0/24 -o enp1s0 -j MASQUERADE
      '';

      peers = [
        # Macbook
        {
          publicKey = "tIsnNtRJx7pHT0Make8FfSQcnvobqUmU+6e4A+E2oCs=";
          allowedIPs = [ "192.168.70.102/32" ];
        }
      ];
    };
  };

  # make it a router
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    # "net.ipv6.conf.all.forwarding" = 1;
    # "net.ipv6.conf.all.proxy_ndp" = 1;
  };

}≤