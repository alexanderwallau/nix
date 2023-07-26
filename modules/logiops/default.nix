{ lib, config, pkgs, ... }:

let cfg = config.awallau.logiops;

in with lib; {
  options.awallau.logiops = {
    enable = mkEnableOption "Enables Logiops for  MX Master 3";
  };

  config = mkIf cfg.enable {
    services.logiops = {
      enable = true;

      settings = {
        devices = [{
          name = "Wireless Mouse MX Master 3";
          smartshift = {
            on = true;
            # 0 means always in hyperfast mode, 50 means (almost) always in click-to-click mode.
            threshold = 25;
          };
          hiresscroll = {
            hires = true;
            invert = false;
            target = false;
          };
          dpi = 700;

          buttons = [
            {
              cid = 195; # 0xc3
              action = {
                type = "Gestures";
                gestures = [
                  ({
                    direction = "Up";
                    mode = "OnRelease";
                    action = {
                      type = "Keypress";
                      keys = [ "KEY_UP" ];
                    };
                  })
                  ({
                    direction = "Down";
                    mode = "OnRelease";
                    action = {
                      type = "Keypress";
                      keys = [ "KEY_DOWN" ];
                    };
                  })
                  ({
                    direction = "Left";
                    mode = "OnRelease";
                    action = {
                      type = "CycleDPI";
                      dpis = [ 700 ];
                    };
                  })
                  ({
                    direction = "Right";
                    mode = "OnRelease";
                    action = { type = "ToggleSmartshift"; };
                  })
                  ({
                    direction = "None";
                    mode = "NoPress";
                  })
                ];
              };
            }
            {
              cid = 196; # 0xc4
              action = {
                type = "Keypress";
                keys = [ "KEY_A" ];
              };
            }
          ];
        }];
      };
    };
  };
}