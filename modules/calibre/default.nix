{ config, lib, ... }:

let
  cfg = config.awallau.calibre;

  pathsAreNested = first: second:
    lib.hasPrefix "${toString first}/" (toString second)
    || lib.hasPrefix "${toString second}/" (toString first);
in
{
  options.awallau.calibre = {
    enable = lib.mkEnableOption "Calibre with the Calibre-Web Automated frontend";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "calibre.alexanderwallau.de";
      description = "Public domain of the Calibre frontend.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8083;
      description = "Loopback port used by nginx to reach Calibre-Web Automated.";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/crocodilestick/calibre-web-automated:v4.0.6";
      description = "Calibre-Web Automated OCI image. This image includes the Calibre binaries.";
    };
    # As per usual one could hardcode this but wha not make an option at 0 cost
    configDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/calibre-web-automated";
      description = "Persistent Calibre-Web Automated configuration directory.";
    };

    libraryDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/calibre-library";
      description = "Persistent Calibre library containing metadata.db and the books.";
    };

    ingestDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/calibre-ingest";
      description = ''
        Incoming-book directory. Calibre-Web Automated removes files from this
        directory after importing them into the library.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Test if this is nested, it shouldnt so you get a nice error during build
    assertions = [
      {
        assertion = !pathsAreNested cfg.configDir cfg.libraryDir
          && !pathsAreNested cfg.configDir cfg.ingestDir
          && !pathsAreNested cfg.libraryDir cfg.ingestDir
          && cfg.configDir != cfg.libraryDir
          && cfg.configDir != cfg.ingestDir
          && cfg.libraryDir != cfg.ingestDir;
        message = "awallau.calibre configDir, libraryDir, and ingestDir must be separate, non-nested directories.";
      }
    ];


    systemd.tmpfiles.settings."10-calibre" = {
      ${cfg.configDir}.d = {
        mode = "0750";
        # Rando spawning function users
        user = "calibre";
        group = "calibre";
      };
      ${cfg.libraryDir}.d = {
        mode = "0750";
      };
      ${cfg.ingestDir}.d = {
        mode = "0750";
      };
    };

    virtualisation.oci-containers.containers.calibre-web-automated = {
      autoStart = true;
      image = cfg.image;
      ports = [ "127.0.0.1:${toString cfg.port}:8083" ];
      volumes = [
        "${cfg.configDir}:/config"
        "${cfg.ingestDir}:/cwa-book-ingest"
        "${cfg.libraryDir}:/calibre-library"
      ];
      environment = {
        TZ = "Europe/Berlin";
        # This does not live on a networked drive, yet
        NETWORK_SHARE_MODE = "False";
        TRUSTED_PROXY_COUNT = "1";
      };
      # One could but nothing needed comes to mind
      #environmentFiles = cfg.environmentFiles;
      #extraOptions = cfg.extraOptions;
    };

    services.nginx.virtualHosts.${cfg.domain} = {
        enableACME = true;
        forceSSL = true;
        # E Books may be large so this allows for sheer infinite upload size
        extraConfig = ''
          client_max_body_size 0;
          proxy_buffering off;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
  };
}
