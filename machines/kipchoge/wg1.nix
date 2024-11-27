{ config, lib, pkgs, ... }: {
sops.secrets ={
      "kipchoge-wg1-private-key" = { };
      "kipchoge-wg1-preshared-key" = { };
    };
  networking = {
    wireguard.interfaces.wg1 = {

      ips = [ "192.168.178.201/24" ];
      mtu = 1412;

      privateKeyFile = toString config.sops.secrets."kipchoge-wg1-private-key".path;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 192.168.69.0/24 -d 192.168.178.0/24 -o wg1 -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 192.168.69.0/24 -d 192.168.178.0/24 -o wg1 -j MASQUERADE
      '';

      peers = [{
        publicKey = "IPyxZ2Sa2UsJwvVMYh8yyidi1hIlKdcgnyKSEldL/Qk=";
        presharedKeyFile = toString config.sops.secrets."kipchoge-wg1-preshared-key".path;
        allowedIPs = [ "192.168.178.0/24" ];
        endpoint = "awll.goip.de:53796";
        persistentKeepalive = 15;
        dynamicEndpointRefreshSeconds = 300;
        dynamicEndpointRefreshRestartSeconds = 10;
      }];

    };
  };


}
