{ config, lib, pkgs, ... }: {

  networking = {
    firewall.allowedUDPPorts = [ 52192 ];
    wireguard.interfaces.wg0 = {

      ips = [ "192.168.69.2/24" ];
      listenPort = 52192;
      mtu = 1412;
      privateKeyFile = toString config.sops.secrets."mayer-wg-private-key".path;

      peers = [
        {
          # Public key of the server (not a file path).
          publicKey = "VVVqrs6Nxn3MxsTWD+mSFzVJQZpWcY4xMCYOwI70BFU=";
          allowedIPs = [ "192.168.69.0/24" "192.168.178.0/24" ];
          # Set this to the server IP and port.
          endpoint = "s3.alexanderwallau.de:52192";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
