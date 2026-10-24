{ config, pkgs, lib, ... }:

let
  sessionSupervisor = pkgs.writeShellScriptBin "session-supervisor" ''
    #!/usr/bin/env bash
    STATE_FILE="''${XDG_RUNTIME_DIR}/session-target"
    echo "sway" > "$STATE_FILE"

    while true; do
      TARGET=$(cat "$STATE_FILE")
      case "$TARGET" in
        gamescope)
          WLR_NO_HARDWARE_CURSORS=1 ${pkgs.gamescope}/bin/gamescope -f -- steam -gamepadui
          echo "sway" > "$STATE_FILE"
          ;;
        *)
          WLR_NO_HARDWARE_CURSORS=1 sway
          ;;
      esac
    done
  '';

  gameMode = pkgs.writeShellScriptBin "game-mode" ''
    echo "gamescope" > "''${XDG_RUNTIME_DIR}/session-target"
    swaymsg exit
  '';
in
{
  environment.systemPackages = [ sessionSupervisor gameMode ];

  services.displayManager.sessionPackages = [
    (pkgs.writeTextDir "share/wayland-sessions/supervisor.desktop" ''
      [Desktop Entry]
      Name=Sway/Gamescope Supervisor
      Comment=Swaps between sway and gamescope without logging out
      Exec=${sessionSupervisor}/bin/session-supervisor
      Type=Application
    '')
  ];
}
