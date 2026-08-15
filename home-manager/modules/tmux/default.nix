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
      # Automatically spawn a session if trying to attach and none are running.
      newSession = true;
      # Base index for windows and panes.
      baseIndex = 1;
      # Less command delay
      escapeTime = 20;
      terminal = "xterm-256color";
      clock24 = true; 
      shortcut = "C-a";
      historyLimit = 10000;
      plugins = with pkgs.tmuxPlugins; [ tmux-fzf  dracula weather];
      extraConfig = ''
      # Status Bar
      set -g status-position bottom
      set -g status-interval 1
      set -g status-left "#{host} #{session_name} #{pane_title} "
      set -g status-left-length 50
      set -g status-right "%Y-%m-%d %H:%M #{cpu_percentage} #{ram_percentage}"
      set -g status-right-length 50
      # Theme configuration
      set -g @dracula-show-battery false
      set -g @dracula-show-weather true
      set -g @dracula-show-powerline false
      '';
    };
  };

}