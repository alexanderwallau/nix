{ pkgs, lib, config, ... }:
with lib;
let cfg = config.awallau.programs.direnv;
in
{

  options.awallau.programs.direnv = {
    enable = mkEnableOption "activate direnv";
  };

  config = mkIf cfg.enable {

    programs = {
      direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = false; # instant does this
        nix-direnv.enable = true;
      };
      zsh.initContent = ''
        eval "$(${direnv-instant-package}/bin/direnv-instant hook zsh)"
        '';
      git = { ignores = [ ".direnv/" ]; };
      vscode.profiles.default = { extensions = with pkgs.vscode-extensions; [ mkhl.direnv ]; };
    };
    # Makes things better
    home.packages = [
      direnv-instant-package
    ];
  };

}
