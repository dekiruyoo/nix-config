# Configuration for videogames. Mostly Touhou. Only made to work with ./swaybar.nix
# Regret: This is useless. I could have made all of this a simple shell script that starts the game, changes the wallpaper and initiates keyd, but instead i vibe coded a whole thing that detects whether or not touhou is running on sway. I'm only keeping this because I'm too tired to change any of this back.
{
  pkgs,
  lib,
  ...
}:
let
  user = "muffy";
  touhouWalls = "./Pictures/touhou/";

  games = {
    "06" = {
      name = "Embodiment of Scarlet Devil";
      message = "The moon turns red as the scarlet mist spreads.";
      wallpaper = "${touhouWalls}/th06.png";
    };
    "07" = {
      name = "Perfect Cherry Blossom";
      message = "Spring arrives, yet the winter wind refuses to leave.";
      wallpaper = "${touhouWalls}/th07.png";
    };
    "08" = {
      name = "Imperishable Night";
      message = "A night that never ends, under a moon that never sets.";
      wallpaper = "${touhouWalls}/th08.png";
    };
    "09" = {
      name = "Phantasmgoria of Flower View";
      message = "The scent of flowers marks the ticking of the hour.";
      wallpaper = "${touhouWalls}/th09.png";
    };
    "10" = {
      name = "Mountain of Faith";
      message = "The mountain peaks touch the edge of heaven.";
      wallpaper = "${touhouWalls}/th10.png";
    };
    #"11" = { # Placeholder for future reference.
    #  name = "";
    #  message = "";
    #  wallpaper = "${touhouWalls}/th11.png";
    #};
  };

  wallpaperFallback = "${touhouWalls}/fbck.png";
  wallpaperNormal = "${touhouWalls}../_wallpaper/youmurs.gif";

  gameColor = "#8b1a2b";
  normalColor = "#1e1e2e";
  cssFile = "/home/${user}/.config/waybar/theme-dynamic.css";

  dunstTemplate = pkgs.writeText "dunst-colors.conf" ''
    [global]
        frame_color = "{{colors.primary.default.hex}}"

    [urgency_low]
        background = "{{colors.primary.default.hex}}"
        foreground = "{{colors.on_primary.default.hex}}"
        frame_color = "{{colors.primary_container.default.hex}}"

    [urgency_normal]
        background = "{{colors.primary.default.hex}}"
        foreground = "{{colors.on_primary.default.hex}}"
        frame_color = "{{colors.primary_container.default.hex}}"

    [urgency_critical]
        background = "{{colors.error.default.hex}}"
        foreground = "{{colors.on_error.default.hex}}"
        frame_color = "{{colors.error_container.default.hex}}"
  '';

  matugenTemplate = pkgs.writeText "waybar-colors.css" ''
    @define-color bar_bg     {{colors.surface.default.hex}};
    @define-color bar_fg     {{colors.on_surface.default.hex}};
    @define-color bar_accent {{colors.primary.default.hex}};
  '';

  matugenConfig = pkgs.writeText "matugen-config.toml" ''
    [config]

    [templates.waybar]
    input_path  = "${matugenTemplate}"
    output_path = "${cssFile}"

    [templates.dunst]
    input_path  = "${dunstTemplate}"
    output_path = "/home/${user}/.config/dunst/dunstrc.d/50-matugen.conf"
  '';

  caseFor =
    field: default:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (n: g: "${n}) echo ${lib.escapeShellArg (g.${field} or default)} ;;") games
    );

  touhou-mode = pkgs.writeShellApplication {
    name = "touhou-mode";
    runtimeInputs = with pkgs; [
      sway
      jq
      keyd
      awww
      procps
      coreutils
      libnotify
      matugen
      dunst
    ];
    text = ''
      state="none"
      keys="off"
      g_game=none
      g_foc=none

      name_for() {
        case "$1" in
          ${caseFor "name" "Touhou"}
          *) echo "Touhou $1" ;;
        esac
      }

      message_for() {
        case "$1" in
          ${caseFor "message" "Z→J, X→K remap active"}
          *) echo "Z→J, X→K remap active" ;;
        esac
      }

      wallpaper_for() {
        case "$1" in
          ${caseFor "wallpaper" wallpaperFallback}
          *) echo "${wallpaperFallback}" ;;
        esac
      }

      # theme <wallpaper> <fallback-color>
      theme() {
        mkdir -p "/home/${user}/.config/dunst/dunstrc.d"
        if ! matugen image "$1" --mode dark --source-color-index 0 --config ${matugenConfig}; then
          printf '@define-color bar_bg %s;\n@define-color bar_fg #ffffff;\n@define-color bar_accent %s;\n' "$2" "$2" > "${cssFile}"
        fi
        dunstctl reload || true
      }

      set_keys() {
        if [ "$1" = on ]; then
          keyd bind 'j = z' 'k = x' || true
        else
          keyd bind reset || true
        fi
      }

      detect() {
        local pid="$1" cls="$2" title="$3" cmd="" hay n

        # 1. Native Wine/XWayland style: class is literally th06.exe
        if [[ "$cls" =~ ^[Tt][Hh]([0-9]+)\.exe$ ]]; then
          echo "''${BASH_REMATCH[1]}"; return
        fi

        # 2. Only look deeper at Proton windows
        [[ "$cls" == steam_proton || "$cls" == steam_app_* ]] || { echo none; return; }

        if [ "$pid" != 0 ] && [ -r "/proc/$pid/cmdline" ]; then
          cmd=$(tr '\0' ' ' < "/proc/$pid/cmdline" || true)
        fi

        # 2a. th08.exe in the command line
        if [[ "$cmd" =~ [Tt][Hh]([0-9]+)\.exe ]]; then
          echo "''${BASH_REMATCH[1]}"; return
        fi

        # 2b. Install path like C:\Games\Touhou_8_Imperishable_Night\...
        hay="$title $cmd"
        if [[ "$hay" =~ Touhou_([0-9]+)_ ]]; then
          n=$((10#''${BASH_REMATCH[1]}))
          printf '%02d\n' "$n"; return
        fi

        # 2c. Window title (English patch titles and the original Japanese ones)
        case "$hay" in
          *"Scarlet Devil"*|*紅魔郷*)               echo 06 ;;
          *"Perfect Cherry"*|*妖々夢*)              echo 07 ;;
          *"Imperishable Night"*|*永夜抄*)          echo 08 ;;
          *"Flower View"*|*花映塚*)                 echo 09 ;;
          *"Mountain of Faith"*|*風神録*)           echo 10 ;;
          *"Subterranean Animism"*|*地霊殿*)        echo 11 ;;
          *"Undefined Fantastic"*|*星蓮船*)         echo 12 ;;
          *)                                        echo none ;;
        esac
      }

      apply_theme() {
        local wp
        if [ "$1" != none ]; then
          wp="$(wallpaper_for "$1")"
          awww img "$wp" --transition-type fade || true
          theme "$wp" "${gameColor}"
          notify-send -a touhou-mode -u low -t 5000 \
            "$(name_for "$1")" "$(message_for "$1")"
        else
          awww img "${wallpaperNormal}" --transition-type fade || true
          theme "${wallpaperNormal}" "${normalColor}"
          notify-send -a touhou-mode -u low -t 3000 \
            "The incident appears to be resolved." "Returning keys to normal..."
        fi
      }

      scan() {
        local focused pid cls title n
        g_game=none
        g_foc=none
        while IFS='|' read -r focused pid cls title; do
        n=$(detect "$pid" "$cls" "$title")
        if [ "$n" != none ]; then
          if [ "$g_game" = none ]; then g_game=$n; fi
          if [ "$focused" = true ]; then g_foc=$n; fi
        fi
        done < <(swaymsg -t get_tree | jq -r '
        [.. | objects | select(.pid? != null)] | .[]
        | "\(.focused)|\(.pid)|\(.app_id // .window_properties.class // "")|\(.name // "")"')
      }

      check() {
        local want=off game

        scan

        # Grace period: a game seemed to vanish, so make sure it's really gone
        if [ "$g_game" = none ] && [ "$state" != none ]; then
          sleep 4
          scan
        fi

        game=$g_game
        if [ "$g_foc" != none ]; then game=$g_foc; want=on; fi

        if [ "$want" != "$keys" ]; then
          keys=$want
          set_keys "$want"
        fi
        if [ "$game" != "$state" ]; then
          state=$game
          apply_theme "$game"
        fi
      }

      check
      swaymsg -t subscribe -m '["window"]' | while read -r _; do check; done
    '';
  };
in
{
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = { };
    };
  };

  users.groups.keyd = { };
  users.users."muffy".extraGroups = [ "keyd" ];

  # Give the keyd group access to the socket once the daemon creates it
  systemd.services.keyd.serviceConfig.CapabilityBoundingSet = [ "CAP_SETGID" ];

  home-manager.users.${user} = { lib, ... }: {
    home.activation.touhouTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      f="$HOME/.config/waybar/theme-dynamic.css"
      mkdir -p "$(dirname "$f")"
      [ -e "$f" ] || printf '@define-color bar_bg #1e1e2e;\n@define-color bar_fg #ffffff;\n@define-color bar_accent #8b1a2b;\n' > "$f"
    '';
  };
  environment.systemPackages = [ touhou-mode ];
}
