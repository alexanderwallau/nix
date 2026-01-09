{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.changedetection-io;
in
{
  options.awallau.changedetection-io = {

    enable = mkEnableOption "activate changedetection.io";

    domain = mkOption {
      type = types.str;
      default = "change.detection.io";
      description = "instance url of changedetection";
    };

    port = mkOption {
      type = types.port;
      default = 10480;
      description = "Port being used for connections between CHangedetection and reverse Proxy (in this case nginx)";
    };
    chromePort = mkOption {
      type = types.port;
      default = 10481;
      description = "A free port on which webDriverSupport or playwrightSupport listen on localhost.";
    };

    maxMemory = mkOption {
      type = types.str;
      default = "500M";
      description = "Playwright can currently leak memory. To mitigate this, we can limit the memory usage of the systemd service. This is a workarround waiting for a propper upstreamfix";
    };

  };

  config = mkIf cfg.enable {

    services = {
      changedetection-io = {
        enable = true;
        port = cfg.port;
        listenAddress = "127.0.0.1";
        # I do want a seperate group for this 
        user = "changedetection-io";
        group = "changedetection-io";
        behindProxy = true;
        baseURL = cfg.domain;
        chromePort = cfg.chromePort;
        datastorePath = "/var/lib/changedetection-io";
        # Currently do not do this decrarativly          
        # environmentFile = null; # Path to a file containing environment variables, for example for SALTED_PASS 
        # Only one technology concurrently is supported
        playwrightSupport = true; # Enable Playwright support for web scraping.
        webDriverSupport = false; # Enable WebDriver support for web scraping.
      };

      nginx = {
        enable = true;
        recommendedOptimisation = true;
        recommendedTlsSettings = true;
        recommendedProxySettings = true;
        virtualHosts.${cfg.domain} = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${builtins.toString cfg.port}";
            recommendedProxySettings = true;
          };
        };
      };

    };
    # Playwright can currently leak memory. See https://github.com/dgtlmoon/changedetection.io/wiki/Playwright-content-fetcher#playwright-memory-leak
    # To mitigate this, we can limit the memory usage of the service.
    # This is a workaround until the issue is resolved upstream.
    # Allegedly this has been fixed cannot tell conclusivly so better safe then sorry 
    systemd.services.changedetection-io.serviceConfig = {
      MemoryMax = cfg.maxMemory;
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}
