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
        lfs.enable = true;
        settings = {
          extraConfig = { pull.rebase = false; };
          user = {
            email = "alexander.wallau@gmx.net";
            name = "alexanderwallau";
          };
          signing = {
            format = "openpgp";
            key = "AF68C38D2E1A5BDB63812D3545DBFBC91D9CF0BB";
            signByDefault = true;
          };
          aliases = {
            co = "checkout";
            p = "pull";
            ps = "push";
            s = "status";
          };
        };

        attributes = [ "*.pdf diff=pdf" ];
        ignores = [
          "*.aux"
          "*.lof"
          "*.log"
          "*.lot"
          "*.fls"
          "*.out"
          "*.toc"
          "*.fmt"
          "*.fot"
          "*.cb"
          "*.cb2"
          ".*.lb"
          "*.fdb_latexmk"
          "*.synctex"
          "*.synctex(busy)"
          "*.synctex.gz"
          "*.synctex.gz(busy)"
          "*.pdfsync"
          ".DS_Store"
          ".AppleDouble"
          ".LSOverride"
          ".direnv"
          "result"
          ".ipynb_checkpoints"
          "#Pipfile.lock"
          "#poetry.lock"
          "__pypackages__/"
          ".env"
          ".venv"
          "env/"
          "venv/"
          "#.idea/"
        ];

      };

      diff-so-fancy.enable = true;

    };
    home.packages = [ pkgs.pre-commit ];

  };
}
