#
#   █████████                                         ██████   █████   ███   █████                      █████
#  ███░░░░░███                                       ███░░███ ░░███   ░███  ░░███                      ░░███
# ░███    ░░░  █████ ███ █████  ██████   █████ ████ ░░██████   ░███   ░███   ░███   ██████   █████ ████ ░███████   ██████   ████████
# ░░█████████ ░░███ ░███░░███  ░░░░░███ ░░███ ░███   ██████    ░███   ░███   ░███  ░░░░░███ ░░███ ░███  ░███░░███ ░░░░░███ ░░███░░███
#  ░░░░░░░░███ ░███ ░███ ░███   ███████  ░███ ░███ ░███░░███   ░░███  █████  ███    ███████  ░███ ░███  ░███ ░███  ███████  ░███ ░░░
#  ███    ░███ ░░███████████   ███░░███  ░███ ░███ ░███ ░░███   ░░░█████░█████░    ███░░███  ░███ ░███  ░███ ░███ ███░░███  ░███
# ░░█████████   ░░████░████   ░░████████ ░░███████ ░░█████░███    ░░███ ░░███     ░░████████ ░░███████  ████████ ░░████████ █████
#  ░░░░░░░░░     ░░░░ ░░░░     ░░░░░░░░   ░░░░░███  ░░░░░ ░░░      ░░░   ░░░       ░░░░░░░░   ░░░░░███ ░░░░░░░░   ░░░░░░░░ ░░░░░
#                                        ███ ░███                                            ███ ░███
#                                       ░░██████                                            ░░██████
#                                        ░░░░░░                                              ░░░░░░

{ pkgs, ... }:

{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  systemd.user.targets.graphical-session = {
    after = [ "sway-session.target" ];
    requires = [ "sway-session.target" ];
  };

  environment.systemPackages = with pkgs; [
    swaylock-effects
    awww
    libnotify
    matugen
  ];

  # Nvidia + wlroots workarounds
  environment.sessionVariables = {
    SWAY_UNSUPPORTED_GPU = "true"; # Proprietary drivers dakara.
  };

  # Screen sharing, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  # Ask for root password
  security.polkit.enable = true;

  home-manager.users."muffy" = { pkgs, lib, ... }: {
    systemd.user.services =
      let
        swaySessionFix = extraPartOf: {
          Unit = {
            After = lib.mkForce [ "sway-session.target" ];
            PartOf = lib.mkForce ([ "sway-session.target" ] ++ extraPartOf);
            ConditionEnvironment = lib.mkForce "";
          };
          Service.ExecStartPre = ''
            ${pkgs.bash}/bin/bash -c 'while [ -z "$(${pkgs.systemd}/bin/systemctl --user show-environment | ${pkgs.gnugrep}/bin/grep WAYLAND_DISPLAY)" ]; do ${pkgs.coreutils}/bin/sleep 0.2; done'
          '';
          Install.WantedBy = lib.mkForce [ "sway-session.target" ];
        };
      in
      {
        swayidle = swaySessionFix [ ];
        waybar = swaySessionFix [ "tray.target" ];
      };
    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 100;
          command = "${pkgs.coreutils}/bin/pgrep -x swaylock || ${pkgs.swaylock-effects}/bin/swaylock --screenshots --effect-blur 7x5 --effect-vignette 0.5:0.5 --clock --indicator --ring-color 1e1e2e --key-hl-color 89b4fa";
        }
        {
          timeout = 600;
          command = "${pkgs.sway}/bin/swaymsg 'output * power off'";
          resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * power on' && ${pkgs.coreutils}/bin/sleep 5";
        }
      ];
      events = {
        before-sleep = "${pkgs.coreutils}/bin/pgrep -x swaylock || ${pkgs.swaylock-effects}/bin/swaylock -f --screenshots --effect-blur 7x5 --effect-vignette 0.5:0.5 --clock --indicator --ring-color 1e1e2e --key-hl-color 89b4fa";
      };
    };

    # Notification Daemon
    services.dunst = {
      enable = true;
      settings.global = {
        corner_radius = 12;
        frame_width = 2;
        padding = 14;
        horizontal_padding = 16;
        font = "sans 11";
        width = "(0, 400)";
      };
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true; # starts as an user service, not a sway `exec` line
      settings.mainBar = {
        "reload_style_on_change" = true;
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "network"
          "pulseaudio"
          "cpu"
          "memory"
          "tray"
        ];

        "sway/workspaces".disable-scroll = true;
        clock.format = "{:%Y-%m-%d %H:%M}";
        network.format = "{ifname}: {ipaddr}";
        pulseaudio.format = "{volume}% {icon}";
        cpu.format = "CPU {usage}%";
        memory.format = "RAM {used:0.1f}G/{total:0.1f}G";
      };

      style = ''
        @import url("file:///home/muffy/.config/waybar/theme-dynamic.css");

        * {
            font-family: monospace;
            font-size: 13px;
          }
        window#waybar {
            background: rgba(30, 30, 46, 0.9);
            color: #cdd6f4;
          }
        window#waybar { background: @bar_bg; color: @bar_fg; }
        #workspaces button.focused { border-bottom: 2px solid @bar_accent; }
      '';
    };

    wayland.windowManager.sway = {
      enable = true;
      config = {
        modifier = "Mod4";
        terminal = "foot";
        menu = "fuzzel";
        gaps = {
          inner = 2;
          outer = 2;
        };
        bars = [ ]; # NO I3STATUS IN THIS HOUSE/

        focus.followMouse = false;
        window = {
          titlebar = false;
          border = 2;
        };
        floating = {
          titlebar = false;
          border = 2;
        };

        # Keyboard layout
        input."*" = {
          xkb_layout = "br";
          xkb_variant = "thinkpad";
        };

        startup = [
          { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
          { command = "${pkgs.awww}/bin/awww-daemon"; }
          { command = "${pkgs.awww}/bin/awww "; }
          #{command = "sleep 1 && ${pkgs.awww}/bin/awww img /home/muffy/Pictures/_wallpaper/youmurs.gif --transition-type fade";}
          { command = "exec touhou-mode"; }
        ];

        # Keybindings
        keybindings =
          let
            mod = "Mod4";
          in
          {
            # --- Default sway: basics ---
            "${mod}+Return" = "exec foot";
            "${mod}+q" = "kill";
            "${mod}+r" = "exec fuzzel";
            "${mod}+Shift+c" = "reload";
            "${mod}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'";

            # --- Default sway: focus movement (vim-style, home row) ---
            "${mod}+h" = "focus left";
            "${mod}+j" = "focus down";
            "${mod}+k" = "focus up";
            "${mod}+l" = "focus right";
            # --- Default sway: focus movement (arrow key alternative) ---
            "${mod}+Left" = "focus left";
            "${mod}+Down" = "focus down";
            "${mod}+Up" = "focus up";
            "${mod}+Right" = "focus right";

            # --- Default sway: move window (vim-style) ---
            "${mod}+Shift+h" = "move left";
            "${mod}+Shift+j" = "move down";
            "${mod}+Shift+k" = "move up";
            "${mod}+Shift+l" = "move right";
            # --- Default sway: move window (arrow key alternative) ---
            "${mod}+Shift+Left" = "move left";
            "${mod}+Shift+Down" = "move down";
            "${mod}+Shift+Up" = "move up";
            "${mod}+Shift+Right" = "move right";

            # --- Default sway: workspaces 1-10 ---
            "${mod}+1" = "workspace number 1";
            "${mod}+2" = "workspace number 2";
            "${mod}+3" = "workspace number 3";
            "${mod}+4" = "workspace number 4";
            "${mod}+5" = "workspace number 5";
            "${mod}+6" = "workspace number 6";
            "${mod}+7" = "workspace number 7";
            "${mod}+8" = "workspace number 8";
            "${mod}+9" = "workspace number 9";
            "${mod}+0" = "workspace number 10";
            "${mod}+Shift+1" = "move container to workspace number 1";
            "${mod}+Shift+2" = "move container to workspace number 2";
            "${mod}+Shift+3" = "move container to workspace number 3";
            "${mod}+Shift+4" = "move container to workspace number 4";
            "${mod}+Shift+5" = "move container to workspace number 5";
            "${mod}+Shift+6" = "move container to workspace number 6";
            "${mod}+Shift+7" = "move container to workspace number 7";
            "${mod}+Shift+8" = "move container to workspace number 8";
            "${mod}+Shift+9" = "move container to workspace number 9";
            "${mod}+Shift+0" = "move container to workspace number 10";

            # --- Default sway: layout ---
            "${mod}+b" = "splith";
            "${mod}+v" = "splitv";
            "${mod}+s" = "layout stacking";
            "${mod}+w" = "layout tabbed";
            "${mod}+e" = "layout toggle split";
            "${mod}+f" = "fullscreen";
            "${mod}+Shift+space" = "floating toggle";
            "${mod}+space" = "focus mode_toggle";
            "${mod}+a" = "focus parent";

            # --- Default sway: scratchpad ---
            "${mod}+Shift+minus" = "move scratchpad";
            "${mod}+minus" = "scratchpad show";

            # --- Default sway: enter resize mode ---
            "${mod}+Shift+r" = ''mode "resize"'';

            # --- Custom, added this conversation ---
            "Print" = "exec grim";
          };

        modes = {
          # --- Default sway: resize mode ---
          resize = {
            "h" = "resize shrink width 10px";
            "j" = "resize grow height 10px";
            "k" = "resize shrink height 10px";
            "l" = "resize grow width 10px";
            "Left" = "resize shrink width 10px";
            "Down" = "resize grow height 10px";
            "Up" = "resize shrink height 10px";
            "Right" = "resize grow width 10px";
            "Return" = ''mode "default"'';
            "Escape" = ''mode "default"'';
          };
        };
      };
    };
  };
}
