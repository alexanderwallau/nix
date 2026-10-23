{ lib, pkgs, config, self, ... }:
with lib;
let 
  cfg = config.awallau.nginx;
  securityTxt = pkgs.runCommand "security.txt" {
    ts = toString self.lastModified;   # unix time of last bild sorta somewhat elegant or so
    } ''
    expires=$(date -u -d "@$((ts + 365 * 86400))" +%Y-%m-%dT%H:%M:%SZ)
    cat > $out <<EOF
    Contact: mailto:kontakt@alexanderwallau.de
    Expires: $expires
    Encryption: https://keys.openpgp.org/vks/v1/by-fingerprint/25121E72847D5226FEF57BC09FAA4DA547D6AD70
    Preferred-Languages: en, de
    Canonical: https://alexanderwallau.de/.well-known/security.txt
    EOF
    '';
  robotsTxt = pkgs.writeText "robots.txt" ''
      User-agent: GPTBot
      Disallow: /
      User-agent: CCBot
      Disallow: /
      User-agent: Google-Extended
      Disallow: /
      User-agent: ClaudeBot
      Disallow: /
      User-agent: Bytespider
      Disallow: /
      User-agent: *
      Allow: /
      '';
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


  options.services.nginx.virtualHosts = mkOption {
    type = types.attrsOf (types.submodule {
      config.locations = {
        "= /.well-known/security.txt" = mkDefault {
          alias = "${securityTxt}";
          extraConfig = "default_type text/plain;";
        };
        "= /robots.txt" = mkDefault {
          alias = "${robotsTxt}";
          extraConfig = "default_type text/plain;";
        };
      };
    });
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
      sslCiphers = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384";
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
