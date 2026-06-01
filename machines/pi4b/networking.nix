{ config, lib, pkgs, ... }:
{
  # Because of the way sops works, every "line" needs to be its own file
  sops.secrets = {
    "pi4b-wifi-1-ssid"  = {};
    "pi4b-wifi-1-psk"   = {};
    "pi4b-wifi-2-ssid"  = {};
    "pi4b-wifi-2-psk"   = {};

  };

  # Render .nmconnection keyfiles
  sops.templates."nm-1.nmconnection" = {
    path    = "/etc/NetworkManager/system-connections/1.nmconnection";
    owner   = "root";
    group   = "root";
    mode    = "0600";
    restartUnits = [ "NetworkManager.service" ];
    content = ''
      [connection]
      id=1
      type=wifi
      autoconnect=true

      [wifi]
      mode=infrastructure
      ssid=${config.sops.placeholder."pi4b-wifi-1-ssid"}

      [wifi-security]
      auth-alg=open
      key-mgmt=wpa-psk
      psk=${config.sops.placeholder."pi4b-wifi-1-psk"}

      [ipv4]
      method=auto

      [ipv6]
      method=auto
    '';
  };

  sops.templates."nm-2.nmconnection" = {
    path    = "/etc/NetworkManager/system-connections/2.nmconnection";
    owner   = "root";
    group   = "root";
    mode    = "0600";
    restartUnits = [ "NetworkManager.service" ];
    content = ''
      [connection]
      id=2
      type=wifi
      autoconnect=true

      [wifi]
      mode=infrastructure
      ssid=${config.sops.placeholder."pi4b-wifi-2-ssid"}

      [wifi-security]
      auth-alg=open
      key-mgmt=wpa-psk
      psk=${config.sops.placeholder."pi4b-wifi-2-psk"}

      [ipv4]
      method=auto

      [ipv6]
      method=auto
    '';
  };

  
  networking = {
    # WPA-Supplicant despite us network managering  this thing 
    wireless.enable = true;
    interfaces = {
      wlan0 = {
        useDHCP = true;
        wakeOnLan.enable = true;
      };
    };
    nameservers = [ "192.168.69.1" "1.0.0.1" ];
    networkmanager = {
      enable = true;
    };
    firewall = {
      allowedTCPPorts = [ 80 443 ];
      trustedInterfaces = [ "wg0" ];
    };
    timeServers = [
      "ptbtime1.ptb.de"
      "ptbtime2.ptb.de"
      "ptbtime3.ptb.de"
    ];
  };
}

