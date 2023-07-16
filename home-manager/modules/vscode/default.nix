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
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        brettm12345.nixfmt-vscode
        github.copilot
        ms-python.python
        ms-vscode-remote.remote-ssh
      ];
    };

  };
}
