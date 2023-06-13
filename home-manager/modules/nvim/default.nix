{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.programs.vim;
in
{
  options.awallau.programs.vim.enable = mkEnableOption "setup neovim";

  config = mkIf cfg.enable {

    xdg = {
      enable = true;
      configFile = {

        # nvim_lua_config = {
        #   target = "nvim/lua/config";
        #   source = ./lua/config;
        # };

      };
    };

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      plugins = with pkgs.vimPlugins; [
        ansible-vim
        nvchad
        vim-better-whitespace
        vim-nix
      ];
    };

  };
}
