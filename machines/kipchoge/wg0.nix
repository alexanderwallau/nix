{ config, lib, pkgs, ... }: {

  networking = {
    firewall.allowedUDPPorts = [ 52192 ];
    wireguard.interfaces.wg0 = {

      ips = [ "192.168.69.1/24" ];
      listenPort = 52192;
      mtu = 1412;
      privateKeyFile = toString config.sops.secrets."kipchoge-wg0-private-key".path;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 192.168.69.0/24 -o enp0s6 -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 192.168.69.0/24 -o enp0s6 -j MASQUERADE
      '';

      peers = [
        # Mayer
        {
          publicKey = "ZDf8HXChWL9lRIF1elc4VjSY07zRn0p+JGDeAtkp+lA=";
          allowedIPs = [ "192.168.69.2/32" ];
        }
        # Phelps
        {
          publicKey = "sqBSxPs6lxrPFIK6uNr+9VuOLiytvxl9ST8PFEnbRz0=";
          allowedIPs = [ "192.168.69.3/32" ];
        }
        # pi4b
        {
          publicKey = "bUlY0CKYGhMP69rjj6II7mk2mvnJ/n8txa2ZYFF6rEc=";
          allowedIPs = [ "192.168.69.4/32" ];
        }
        # Werth
        {
          publicKey = "xhzaSbhk9yLPhZjRtK1MpF7UHbEJ66oPVf4irzqULkY=";
          allowedIPs = ["192.168.69.5/32"];
        }
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
        # iPad
        {
          publicKey = "iAUCVa+1Rp3pdlK5wZCsiCtNx80uRCDKhA/1Gus/LEI=";
          allowedIPs = [ "192.168.69.103/32" ];
        }
        # SchmackBook
        {
          publicKey = "sY1JI0u03NWKahjfIWoXkPSpuqqEaqrZmJm7oCi0DBQ=";
          allowedIPs = [ "192.168.69.104/32" ];
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
