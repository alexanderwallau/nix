{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.awallau.programs.tmux;
in
{
  options.awallau.programs.tmux.enable = mkEnableOption "enable tmux";

  config = mkIf cfg.enable {

    programs.tmux = {
      enable = true;
      mouse = true;
      copyMode = true;
      terminal = "xterm-256color";
      clock24 = true; 
      shortcut = "C-a";
      historyLimit = 10000;
    };
  };

}