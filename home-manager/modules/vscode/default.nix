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
      userSettings = {
        "nix" = {
          "enableLanguageServer" = true;
          "serverPath" = "${pkgs.nil}/bin/nil";
          "serverSettings" = {
            "nil" = {
              "formatting" = {
                "command" = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
              };
            };
          };
        };
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };
        "[jsonc]" = {
          "editor.defaultFormatter" = "vscode.json-language-features";
        };
        "editor.cursorBlinking" = "expand";
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.cursorSurroundingLinesStyle" = "all";
        "editor.defaultColorDecorators" = true;
         "editor.formatOnPaste" = true;
        "editor.formatOnSave" = true;
        "editor.formatOnType" = true;
        "editor.linkedEditing" = true;
        "editor.minimap.maxColumn" = 160;
        "editor.mouseWheelZoom" = true;
        "editor.renderWhitespace" = "all";
        "editor.smoothScrolling" = true;
        "files.autoGuessEncoding" = true;
        "files.autoSave" = "afterDelay";
                "nix.serverPath" = "${pkgs.nil}/bin/nil";
        "prettier.printWidth" = 160;
        "problems.showCurrentInStatus" = true;
        "redhat.telemetry.enabled" = false;
      };

      extensions = with pkgs.vscode-extensions; [
        adpyke.codesnap
        dracula-theme.theme-dracula
        eamodio.gitlens
        file-icons.file-icons
        github.copilot
        jnoortheen.nix-ide
        mechatroner.rainbow-csv
        ms-python.python
        ms-toolsai.jupyter
        ms-vscode.cmake-tools
        ms-vscode.cpptools
        ms-vscode.powershell
        ms-vscode-remote.remote-ssh
        ms-vsliveshare.vsliveshare
        oderwat.indent-rainbow
        ritwickdey.liveserver
        valentjn.vscode-ltex
        james-yu.latex-workshop
        ms-toolsai.jupyter
        ms-pyright.pyright
        github.vscode-pull-request-github
        gruntfuggly.todo-tree
        mkhl.direnv
                redhat.vscode-yaml
        streetsidesoftware.code-spell-checker
        tamasfe.even-better-toml
        usernamehw.errorlens
        vadimcn.vscode-lldb
        yzhang.markdown-all-in-one
      ];
    };

  };
}
