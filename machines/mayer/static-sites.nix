{ config, lib, pkgs, ... }:
{
  services.nginx = {
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    virtualHosts = {
      # Uses h5ai for a nice frontend 
      # h5ai not nixed yet need to manually config php
      # More or less a giant Fileserver
      "pdok.alexanderwallau.de" = {
        addSSL = false;
        enableACME = false;
        root = "/var/www/pdok.alexanderwallau.de";
        locations."/" = {
          tryFiles = "$uri $uri/ index.php";
          index = "index.php index.html index.htm";
        };
      };
      # alexanderwallau.de a staticly generated site with hugo auto refreshed with deploy-hugo
      "alexanderwallau.de" = {
        addSSL = true;
        enableACME = true;
        root = "/var/www/alexanderwallau.de";
      };
    };
  };
}
