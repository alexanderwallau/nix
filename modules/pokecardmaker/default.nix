{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.pokecardmaker;

  src = pkgs.fetchFromGitHub {
    owner = "karl";
    repo = "pokecardmaker.net";
    # Main seems stable enough (2 years since last change)
    rev = "main"; 
    sha256 = "sha256-075m3n5cb1ggynbc74yrshcx1wsndf3fqvifx6xn2ir8ji993hgh";
  };

  pokecardmaker = pkgs.buildNpmPackage {
    pname = "pokecardmaker";
    version = "0.1.0";

    inherit src;

    npmDepsHash = lib.fakeHash;
    npmBuildScript = "build";

    installPhase = ''
      mkdir -p $out/app
      cp -r . $out/app
    '';
  };

in
{
  options.awallau.pokecardmaker = {
    enable = lib.mkEnableOption "PokéCardMaker web service";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port PokéCardMaker listens on";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "poke.card.maker";
      description = "Public domain name (for reverse proxies, app config, etc.)";
    };

    envFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to .env file for PokéCardMaker";
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.pokecardmaker = {
      description = "PokéCardMaker.net";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;

        WorkingDirectory = "${pokecardmaker}/app";

        EnvironmentFile = cfg.envFile;
        Environment = [
          "PORT=${toString cfg.port}"
          "DOMAIN=${cfg.domain}"
        ];

        ExecStart = "${pkgs.nodejs}/bin/node ${pokecardmaker}/app/index.js";

        Restart = "on-failure";
      };
    };

  services.nginx = {
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    virtualHosts.${cfg.domain} = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
          };
          extraConfig = ''
            client_max_body_size 256M;
          '';
        };
  };
  };
}
