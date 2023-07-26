{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.programs.git;
in
{
  options.awallau.programs.git.enable = mkEnableOption "enable git";

  config = mkIf cfg.enable {

    programs = {
      git = {
        enable = true;
        # Gitignore ist long so import that
        lfs.enable = true;
        extraConfig = { pull.rebase = false; };
        userEmail = "alexander.wallau@gmx.net";
        userName = "alexanderwallau";

      };
    };
    home.packages = [ pkgs.pre-commit ];

  };
}
