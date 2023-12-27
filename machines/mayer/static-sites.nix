{ self, ... }:
{ config, pkgs, ... }:
{
  services.nginx.virtualHosts = {
    # Uses h5ai for a nice frontend 
    # h5ai not nixed yet need to manually config php
    "pdok.alexanderwallau.de" = {
      addSSL = true;
      enableACME = true;
      root = "/var/www/pdok.alexanderwallau.de";
    };
    "alexanderwallau.de" = {
      addSSL = true;
      enableACME = true;
      root = "/var/www/alexanderwallau.de";
    };
  };
}
