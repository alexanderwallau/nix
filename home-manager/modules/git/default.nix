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
          init.defaultBranch = "main";
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
          pull = {
            rebase = true;
            autostash = true;
            twohead = "ort";
          };
          push = {
            default = "simple";
            autoSetupRemote = true;
          };
          branch = {
            autoSetupRebase = "always";
            autoSetupMerge = "always";
          };
          aliases = {
            a = "add";
            c = "commit -m";
            clean = "clean -xdn";
            co = "checkout";
            d = "diff --output-indicator-new=" " --output-indicator-old=" "";
            l = "log --graph --all --pretty=format:"%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n"";
            p = "pull";
            ps = "push";
            s = "status --short";
            undo = "reset --soft HEAD~1";
            unstage = "reset HEAD --";
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
          "tags"
          "*.swp"
          "result"
          ".claude"
        ];

      };

      diff-so-fancy.enable = true;
      programs.delta = {
        enable = true;
        enableGitIntegration = true;
      };
    };
    home.packages = [ 
      gh 
      glab
      tea
      pkgs.pre-commit 
      ];

  };
}
