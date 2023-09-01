{ lib, pkgs, config, ... }:
with lib;
let cfg = config.awallau.gitea;
in
{

  options.awallau.gitea = {

    enable = mkEnableOption "activate gitea";

  };

  config = mkIf cfg.enable { 
 
 
   services.gitea = {
    enable = true;
    appName = "A personal git server";
    database.user = "git";
    # dump.enable = true;
    # dump.interval = "weekly";
    lfs.enable = true;
    user = "git";   

    settings = {
      server = {
        ROOT_URL = "https://git.alexanderwallau.de";
        DOMAIN = "git.alexanderwallau.de";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 3000;
        SSH_PORT = 22;
      };
      service = {
        DISABLE_REGISTRATION = true;
      };
      session = {
        COOKIE_SECURE = true;
      };
      "repository" = {
        ENABLE_PUSH_CREATE_USER = true;
        ENABLE_PUSH_CREATE_ORG = true;
      };
      "repository.upload" = {
        FILE_MAX_SIZE = "50";
        MAX_FILES = "20";
      };
      "git.timeout" = {
        DEFAUlT = "3600";
        MIGRATE = "600";
        MIRROR = "300";
        CLONE = "300";
        PULL = "300";
        GC = "60";
      };
      "service.explore" = {
        REQUIRE_SIGNIN_VIEW = true;
        DISABLE_USERS_PAGE = true;
      };
      other = {
        SHOW_FOOTER_BRANDING = false;
        SHOW_FOOTER_VERSION = true;
        SHOW_FOOTER_TEMPLATE_LOAD_TIME = true;
      };
      "markup.latex" =
        let
          # have to check if that makes it better
          # https://github.com/go-gitea/gitea/issues/17635
          template-config = builtins.toFile "basic.html" (
            ''
              $for(include-before)$
              $include-before$
              $endfor$
              $if(title)$
              $title$
              $if(subtitle)$
              $subtitle$
              $endif$
              $for(author)$
              $author$
              $endfor$
              $if(date)$
              $date$
              $endif$
              $endif$
              $if(toc)$
              $idprefix$TOC
              $if(toc-title)$
              $toc-title$
              $endif$
              $table-of-contents$
              $endif$
              $body$
              $for(include-after)$
              $include-after$
              $endfor$
            ''
          );
        in
        {
          ENABLED = true;
          FILE_EXTENSIONS = ".tex,.latex";
          RENDER_COMMAND = "timeout 30s ${pkgs.pandoc}/bin/pandoc --pdf-engine=${pkgs.texlive.combined.scheme-full}/bin/pdflatex -f latex -t html --embed-resources --standalone --template ${template-config}";
        };
    };

  };
   services.nginx = {
    virtualHosts = {
      "git.alexanderwallau.de" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:3000";
          extraConfig = ''
            client_max_body_size 256M;
          '';
        };
      };
    };
  };

  users.users = {
    git = {
      description = "Gitea Service";
      home = "/var/lib/gitea";
      useDefaultShell = true;
      group = "gitea";
      isSystemUser = true;
    };
  };

  users.groups.git = { };


};
}

