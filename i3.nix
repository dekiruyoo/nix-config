# i3.nix
{ config, pkgs, ... }:

{
  services.xserver.windowManager.i3.enable = true;

  services.picom = {
    enable = true;
    shadow = true;
    fade = true;
  };

  home-manager.users."muffy" = { pkgs, ... }: {
    xsession.windowManager.i3 = {
      enable = true;
      config = {
        modifier = "Mod4";
        terminal = "foot";
        menu = "fuzzel";

        gaps = {
          inner = 10;
          outer = 5;
        };

        bars = [{
          position = "top";
          statusCommand = "i3status";
        }];

        keybindings = let
          mod = "Mod4";
        in {
          "${mod}+Return" = "exec foot";
          "${mod}+d" = "exec fuzzel";
          "${mod}+Shift+q" = "kill";
          "${mod}+j" = "focus left";
          "${mod}+k" = "focus down";
          "${mod}+l" = "focus up";
          "${mod}+semicolon" = "focus right";
        };

        colors = {
          focused = {
            border = "#89b4fa";
            background = "#1e1e2e";
            text = "#cdd6f4";
            indicator = "#89b4fa";
            childBorder = "#89b4fa";
          };
        };
      };
    };
  };
}
