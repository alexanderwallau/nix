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
        aliases = {
          #Inspired by https://github.com/jayharris/dotfiles-windows/blob/master/home/.gitconfig
          aliases = "!git config --get-regexp ^alias\\. | sed -e s/^alias\\.// -e s/\\ /\\ =\\ / | grep -v ^'alias '";
          # View abbreviated SHA, description, and history graph of the latest 20 commits
          l = log - -pretty -oneline -n 20 --graph --abbrev-commit;
          s = status;
          d = !"git diff-index --quiet HEAD -- || clear; git --no-pager diff --patch-with-stat";
          di = !"d() { git diff --patch-with-stat HEAD~$1; }; git diff-index --quiet HEAD -- || clear; d";
          p = !"git pull; git submodule foreach git pull origin master";
          c = clone - -recursive;
          ca = !git add - A && git commit - av;
          co = checkout;
          go = checkout - B;
          tags = tag - l;
          branches = branch - a;
          remotes = remote - v;
          credit = "!f() { git commit --amend --author \"$1 <$2>\" -C HEAD; }; f";
          reb = "!r() { git rebase -i HEAD~$1; }; r";
          fb = "!f() { git branch -a --contains $1; }; f";
          ft = "!f() { git describe --always --contains $1; }; f";
          fc = "!f() { git log --pretty=format:'%C(yellow)%h  %Cblue%ad  %Creset%s%Cgreen  [%cn] %Cred%d' --decorate --date=short -S$1; }; f";
          fm = "!f() { git log --pretty=format:'%C(yellow)%h  %Cblue%ad  %Creset%s%Cgreen  [%cn] %Cred%d' --decorate --date=short --grep=$1; }; f";
          dm = "!git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";
          uncommit = reset - -soft HEAD;
          };
          };
          };
          home.packages = [ pkgs.pre-commit ];

        };
      }
