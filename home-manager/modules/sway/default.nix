{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.awallau.programs.sway;
  start-sway = pkgs.writeShellScriptBin "start-sway" /* sh */
    ''
      export WLR_DRM_NO_MODIFIERS=1
      dbus-launch --sh-syntax --exit-with-session ${pkgs.sway}/bin/sway
    '';
in
{

  options.awallau.programs.sway = {
    enable = mkEnableOption "enable sway";
    type = mkOption {
      type = types.enum [ "desktop" "laptop" ];
      default = "laptop";
      example = "desktop";
    };
  };

  config = mkIf cfg.enable {

    awallau = {
      programs = {
        waybar.enable = true;
      };
    };

    home.packages = with pkgs;      [
      mako
      start-sway
      wev # find out how a key is called
      wlay
      wl-clipboard
      wlr-randr
      xdg-utils # for opening default programs when clicking links
    ];

    # Use sway desktop environment with Wayland display server
    # https://rycee.gitlab.io/home-manager/options.html#opt-wayland.windowManager.sway.enable

    wayland.windowManager.sway = {

      enable = true;
      wrapperFeatures.gtk = true;

      # Sway-specific Configuration
      config = rec{

        input = {
          "type:keyboard" = {
            xkb_layout = "us";
            xkb_numlock = "enabled";
          };
          "type:touchpad" = {
            click_method = "clickfinger";
            tap = "enabled";
          };
        };

        modifier = "Mod4";

        terminal = "${pkgs.foot}/bin/foot";
        menu = "${pkgs.wofi}/bin/wofi --show run";

        # Status bar(s)
        bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];

        startup = [
          { command = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"; }
        ];

        keybindings = lib.mkOptionDefault (
          (lib.attrsets.mergeAttrsList [

            # general keybindings not specific to laptop or desktop
            (lib.optionalAttrs true {
              # take screenshot of whole screen
              "Print" = "exec ${pkgs.grim}/bin/grim /home/nik/Pictures/Screenshots/Screenshot-$(date +'%Y-%m-%d_%H-%M-%S.png')";
              # control volume
              "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
              "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
              "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
            })

            # desktop specific keybindings
            (lib.optionalAttrs (cfg.type == "desktop") { })

            # laptop specific keybindings
            (lib.optionalAttrs (cfg.type == "laptop") {
              # control brightness
              "XF86MonBrightnessUp" = "exec ${pkgs.light}/bin/light -A 10";
              "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 10";
            })

          ])
        );

        colors = let c = config.pinpox.colors; in {
          focused = {
            background = "#${c.Blue}";
            border = "#${c.BrightBlue}";
            childBorder = "#${c.Blue}";
            indicator = "#${c.BrightBlue}";
            text = "#${c.Black}";
          };
          focusedInactive = {
            background = "#${c.BrightWhite}";
            border = "#${c.BrightBlack}";
            childBorder = "#${c.BrightWhite}";
            indicator = "#${c.BrightBlack}";
            text = "#${c.White}";
          };
          unfocused = {
            background = "#${c.Black}";
            border = "#${c.BrightBlack}";
            childBorder = "#${c.Black}";
            indicator = "#${c.BrightBlack}";
            text = "#${c.BrightBlack}";
          };
          urgent = {
            background = "#${c.Red}";
            border = "#${c.Black}";
            childBorder = "#${c.Red}";
            indicator = "#${c.Red}";
            text = "#${c.White}";
          };
        };
      };

    };

    programs = {
      zsh = {
        shellAliases = rec {
          # energy profiles
          performance = "echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor";
          powersave = "echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor";

          # suspend
          zzz = "${pkgs.swaylock}/bin/swaylock -fF && systemctl suspend";
        };
      };
    };

  };
}
