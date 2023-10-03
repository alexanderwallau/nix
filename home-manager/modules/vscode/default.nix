{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.programs.vscode;
in
{
  options.awallau.programs.vscode.enable = mkEnableOption "enable vscode";

  config = mkIf cfg.enable {

    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      userSettings = {
        "nix" = {
          "enableLanguageServer" = true;
          "serverPath" = "${pkgs.nil}/bin/nil";
          "serverSettings" = {
            "nil" = {
              "formatting" = {
                "command" = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
              };
            };
          };
        };
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };
      };

      extensions = with pkgs.vscode-extensions; [
        github.copilot
        jnoortheen.nix-ide
        ms-python.python
        ms-vscode-remote.remote-ssh
      ];
    };

  };
}
