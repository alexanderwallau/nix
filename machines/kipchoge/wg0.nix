{ config, lib, pkgs, ... }: {

  networking = {
    firewall.allowedUDPPorts = [ 52192 ];
    wireguard.interfaces.wg0 = {

      ips = [ "192.168.69.1/24" ];
      listenPort = 52192;
      mtu = 1412;

      privateKeyFile = toString /var/src/secrets/wireguard/private;
      generatePrivateKeyFile = true;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 192.168.69.0/24 -o enp0s6 -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 192.168.69.0/24 -o enp0s6 -j MASQUERADE
      '';

      peers = [
        # Thinkpad
        {
          publicKey = "Y6v8C//JacOi/EVb80JBtJ7Bv+6viDnfpnS0hmAHUDo=";
          allowedIPs = [ "192.168.69.100/32" ];
        }
        # iPhone
        {
          publicKey = "gzpPYd8REjXsTPRIHs3MF/OJV2nl4YU1p5E0UaDwKCU=";
          allowedIPs = [ "192.168.69.101/32" ];
        }
        # Nik
        {
          publicKey = "+qt2l/mWieG/oJ8GNUpH6pIbCzKaDGOAIgkAn0mi01Y=";
          allowedIPs = [ "192.168.69.102/32" ];
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

}
