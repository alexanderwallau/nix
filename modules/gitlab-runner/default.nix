{ config, pkgs, lib, ... }:
with lib;
let cfg = config.awallau.gitlab-runner;
in
{
  options.awallau.gitlab-runner = with lib;{
    enable = lib.mkEnableOption "activate gitlab-runner(s)";

    dockerImage = mkOption {
      type = types.str;
      default = "python:latest";
      description = "docker image to use for the gitlab-runner";
    };
    registrationConfigFile = mkOption {
      type = types.str;
      default = "/var/run/gitlab-runner/config-1";
      description = "path to the registration file for the gitlab-runner";
    };
  };
  config = mkIf cfg.enable {
    services.gitlab-runner = {
      enable = true;
      # for this case onfigure as litte as possible generally for maximum flexibility
      # main gitlab-cs runner for rust
      services.gitlab-runner-1 = {
        dockerImage = "${cfg.dockerImage}";
        # this registration file needs to be configured for each host individually
        registrationConfigFile = "${cfg.registrationConfigFile}";
      };
      # If you need more runners just copy the config from above and change the name and nessecary variables

      # the config file can look  like this:
      # CI_SERVER_URL={YOUR_URL}
      # REGISTRATION_TOKEN={YOUR_TOKEN}
      # DOCKER_SECURITY_OPT=seccomp:unconfined # required for i.e. cargo tarpaulin
      # DOCKER_SERVICES_SECURITY_OPT=seccomp:unconfined #required for i.e cargo tarpaulin

    };
  };
}
