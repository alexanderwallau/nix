{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.nginx;
in
{

  options.awallau.nginx = {
    enable = mkEnableOption "activate nginx";
    email = mkOption {
      type = types.str;
      default = "acme@alexanderwallau.de";
      description = ''
        Sent exipry notifications to this email address.
      '';
    };
  };

  config = mkIf cfg.enable {

    security.acme.acceptTerms = true;
    security.acme.defaults.email = "${cfg.email}";

    services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;


      # lets be more picky on our ciphers and protocols
      sslCiphers = "EECDH+aRSA+AESGCM:EDH+aRSA:EECDH+aRSA:+AES256:+AES128:+SHA1:!CAMELLIA:!SEED:!3DES:!DES:!RC4:!eNULL";
      sslProtocols = "TLSv1.3 TLSv1.2";
      # Logs  
      commonHttpConfig = ''
        map $remote_addr $remote_addr_anon {
          ~(?P<ip>\d+\.\d+\.\d+)\.    $ip.0;
          ~(?P<ip>[^:]+:[^:]+):       $ip::;
          default                     0.0.0.0;
        }

        log_format combined_anon '$remote_addr_anon - $remote_user [$time_local] '
                                 '"$request" $status $body_bytes_sent '
                                 '"$http_referer" "$http_user_agent"';

        access_log /var/log/nginx/access.log combined_anon buffer=32k flush=5m;
      '';


      # both lines can help if errors occur
      # especially with using longer paths
      clientMaxBodySize = "128m";
      serverNamesHashBucketSize = 128;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

  };
}
