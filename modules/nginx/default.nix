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

      # lets be more picky on our ciphers and protocols
      sslCiphers = "EECDH+aRSA+AESGCM:EDH+aRSA:EECDH+aRSA:+AES256:+AES128:+SHA1:!CAMELLIA:!SEED:!3DES:!DES:!RC4:!eNULL";
      sslProtocols = "TLSv1.3 TLSv1.2";

      # both lines can help if errors occur
      # especially with using longer paths
      clientMaxBodySize = "128m";
      serverNamesHashBucketSize = 128;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

  };
}
