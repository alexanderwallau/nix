{ lib, pkgs, config, ... }:
with lib;
let
  cfg        = config.awallau.containers.solidtime;
  backend    = config.virtualisation.oci-containers.backend;
  backendPkg = pkgs.${backend};
  backendBin = "${backendPkg}/bin/${backend}";
  # Subnet for the solidtime Docker bridge — must match pg_hba rule below
  subnet     = "172.40.0.0/24";

  networkDep = {
    after    = [ "solidtime-network.service" ];
    requires = [ "solidtime-network.service" ];
  };

  sharedVolumes = [
    "${cfg.dataDir}/data:/var/www/html/storage/app"
    "${cfg.dataDir}/logs:/var/www/html/storage/logs"
  ];

in
{
  options.awallau.containers.solidtime = {
    enable = mkEnableOption "activate Solidtime";

    port = mkOption {
      type = types.port;
      default = 7267;
      description = "local port to expose Solidtime on";
    };

    domain = mkOption {
      type = types.str;
      description = "domain name for Solidtime";
      example = "solid.ti.me";
    };

    dataDir = mkOption {
      type = types.str;
      description = "directory to store Solidtime persistent data";
      example = "/var/lib/solidtime";
    };
    # TODO Move multiline secret file to sops
    secretFile = mkOption {
      type = types.path;
      description = ''
        Some secrets
        APP_KEY=base64:...
        DB_PASSWORD=...
      '';
      # Long descripton of what options will be set at the end of the file
    };

  };

  config = mkIf cfg.enable {


    virtualisation.oci-containers.containers = {
      solidtime = {
        autoStart = true;
        image = "solidtime/solidtime:0.11";
        user = "1000:1000";
        networks = [ "solidtime" ];
        # I do want to use the system postgres which suprisingly is not inside a docker network
        ports = [ "127.0.0.1:${toString cfg.port}:8000" ];
        dependsOn = [ "solidtime-gotenberg" ];
        # That has to be a list and the singluar option does not exist :(
        environmentFiles = [ cfg.secretFile ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
        environment = {
          # That they use 1 container for three "modes" is a bit baffeling and massive overhead, but I may not know php best practices
          CONTAINER_MODE = "http";
          AUTO_DB_MIGRATE = "true";
          DB_CONNECTION = "pgsql";
          DB_HOST = "host.docker.internal";
          DB_PORT = "5432";
          DB_DATABASE = "solidtime";
          DB_USERNAME = "solidtime";
          GOTENBERG_URL = "http://solidtime-gotenberg:3000";
        };

        volumes = sharedVolumes;
      };

      solidtime-scheduler = {
        autoStart = true;
        image = "solidtime/solidtime:0.11";
        user = "1000:1000";
        # I speculate that I can get away without a db pasword, that be nice why, because setting that declarativly with this env file is more limbo than not useing one"
        environmentFiles = [ cfg.secretFile ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
        environment = {
          CONTAINER_MODE = "scheduler";
          DB_CONNECTION = "pgsql";
          DB_HOST = "host.docker.internal";
          DB_PORT = "5432";
          DB_DATABASE = "solidtime";
          DB_USERNAME = "solidtime";
        };

        volumes = sharedVolumes;
      };

      solidtime-queue = {
        autoStart = true;
        image = "solidtime/solidtime:0.11";
        user = "1000:1000";

        environmentFiles = [ cfg.secretFile ];
        extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
        environment = {
          CONTAINER_MODE = "worker";
          WORKER_COMMAND = "php /var/www/html/artisan queue:work";
          DB_CONNECTION = "pgsql";
          DB_HOST = "host.docker.internal";
          DB_PORT = "5432";
          DB_DATABASE = "solidtime";
          DB_USERNAME = "solidtime";
        };

        volumes = sharedVolumes;
      };
      # Why this is their pdf solution I do not now, its overkill at best
      solidtime-gotenberg = {
        autoStart = true;
        image = "gotenberg/gotenberg:8";
        networks = [ "solidtime" ];
      };
    };


    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        # For now make it internal only
        extraConfig = ''
          allow 192.168.69.0/24;
          allow 192.168.178.0/24;
          deny all;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };

    # Ensure the DB and user exist in the system postgres
    services.postgresql = {
      # Listen on all interfaces so the container can reach host postgres via host.docker.internal
      settings.listen_addresses = lib.mkForce "*";
      ensureDatabases = [ "solidtime" ];
      ensureUsers = [
        {
          name = "solidtime";
          ensureDBOwnership = true;
        }
      ];
      # Allow connections from Docker bridge subnet
      authentication = pkgs.lib.mkAfter ''
        host solidtime solidtime ${subnet} trust
      '';
    };

    # Open port 5432 for the solidtime Docker bridge — named networks create br-<hash>
    # interfaces that are NOT docker0, so trusting docker0 in the firewall is not enough
    networking.firewall.extraCommands = lib.mkAfter ''
      iptables -A nixos-fw -s ${subnet} -p tcp --dport 5432 -j nixos-fw-accept
    '';
    networking.firewall.extraStopCommands = lib.mkAfter ''
      iptables -D nixos-fw -s ${subnet} -p tcp --dport 5432 -j nixos-fw-accept || true
    '';

    systemd = {
      # Create the solidtime bridge network with a fixed subnet so pg_hba and
      # the firewall rule above match the actual bridge IP range
      services.solidtime-network = {
        description = "Create solidtime container network";
        before = map (n: "${backend}-${n}.service") [
          "solidtime" "solidtime-gotenberg"
        ];
        wantedBy = [ "multi-user.target" ];
        after    = [ "network.target" ];
        serviceConfig = {
          Type            = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "solidtime-net-create" ''
            ${backendBin} network inspect solidtime >/dev/null 2>&1 \
              || ${backendBin} network create --subnet=${subnet} solidtime
          '';
          ExecStop = pkgs.writeShellScript "solidtime-net-rm" ''
            ${backendBin} network rm solidtime 2>/dev/null || true
          '';
        };
      };

      tmpfiles.rules = [
        "d ${cfg.dataDir}      0755 1000 1000 - -"
        "d ${cfg.dataDir}/data 0755 1000 1000 - -"
        "d ${cfg.dataDir}/logs 0755 1000 1000 - -"
      ];
    };
  };
  # What options should be set:
  # APP_KEY
  # PASSPORT_PRIVATE_KEY
  # PASSPORT_PUBLIC_KEY
  # SUPER_ADMINS
  # I wanted Mail but this is higly preferential
  # MAIL_MAILER="""
  # MAIL_HOST="""
  # MAIL_PORT=""
  #MAIL_ENCRYPTION=""
  # MAIL_FROM_ADDRESS="no-reply@your-domain.com"
  # MAIL_FROM_NAME="your-company-name"
  # MAIL_USERNAME="**"
  # MAIL_PASSWORD="**"
  # S3 seems good this depends on when  I will switch from MINIO to garage
  # FILESYSTEM_DISK="s3"
  # PUBLIC_FILESYSTEM_DISK="s3"
  # S3_REGION="fr-par" # fr-par, nl-ams, pl-waw
  # S3_BUCKET="your-bucket-name"
  # S3_ENDPOINT="https://s3.fr-par.scw.cloud" # Replace fr-par with your region
  # S3_ACCESS_KEY_ID="***"
  # S3_SECRET_ACCESS_KEY="***"
  # Larvel shit

  # APP_ENV="production"
  # APP_DEBUG="false"
  # APP_URL="https://your-domain.com"
  # APP_FORCE_HTTPS="false" we reverse proxy
  # APP_ENABLE_REGISTRATION = "false" --> Super Admin does that
}
