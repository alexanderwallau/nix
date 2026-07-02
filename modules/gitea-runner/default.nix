{ config, lib, ... }:
let
  cfg = config.awallau.gitea-runner;
in
{
  options.awallau.gitea-runner = with lib; {
    enable = mkEnableOption "Gitea Actions runner(s)";

    instances = mkOption {
      default = { };
      description = ''
        One entry per Gitea instance to register against. The attr name is the
        default runner name; the sops secret is keyed to the runner name:
        create a secret `gitea-runner-<name>-token` in secrets/secrets.yaml
        whose content is a line `TOKEN=<registration-token>` (EnvironmentFile
        format).
      '';
      example = literalExpression ''
        {
          codeberg.url = "https://codeberg.org";
          internal = {
            url = "https://gitea.example.com";
            labels = [ "ubuntu-latest:docker://node:20-bookworm" ];
          };
        }
      '';
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
            description = "Runner name shown in Gitea. Defaults to the attr key.";
          };
          url = mkOption {
            type = types.str;
            description = "URL of the Gitea instance to register against.";
          };
          labels = mkOption {
            type = types.listOf types.str;
            default = [ "ubuntu-latest:docker://node:20-bookworm" ];
            description = "Runner labels / executor mapping.";
          };
        };
      }));
    };
  };

  config = lib.mkIf cfg.enable {
    # docker executor for the `docker://` labels above; override per host if unused.
    virtualisation.docker.enable = lib.mkDefault true;
    # Trickery so that the secret is tied to the display name
    sops.secrets = lib.mapAttrs'
      (_: inst: lib.nameValuePair "gitea-runner-${inst.name}-token" { })
      cfg.instances;

    services.gitea-actions-runner.instances = lib.mapAttrs
      (name: inst: {
        enable = true;
        inherit (inst) name url labels;
        tokenFile = config.sops.secrets."gitea-runner-${inst.name}-token".path;
      })
      cfg.instances;
  };
}
