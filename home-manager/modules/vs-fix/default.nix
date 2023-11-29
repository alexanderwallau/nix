{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.programs.vs-fix;
in
{
  options.awallau.programs.vs-fix.enable = mkEnableOption "enable vs-fix";

  config = mkIf cfg.enable {

    home.file.vs-fix = {
      target = "shell.nix";
      source = ./shell.nix;
    };

  };
}
