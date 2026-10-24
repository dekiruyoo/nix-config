{ config, pkgs, ... }:

{
  # GPU: GT 1030, needs the legacy driver branch.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580; # Compatible with GT 1030.
  };

  # Use kernel compatible with GT 1030.
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Disk encryption — specific to this machine's physical disk.
  boot.initrd.luks.devices."luks-9e5f5584-7871-469f-88a1-91190fb31789".device =
    "/dev/disk/by-uuid/9e5f5584-7871-469f-88a1-91190fb31789";

  networking.hostName = "t1me";
  networking.wireless.enable = false; # Keeping this for reference.

  services.xserver.enable = true; # Explicitly enabling X11 since most Wayland compositors aren't compatible with Nvidia GPUs.
  services.libinput.enable = false; # No touchpad available.

  # TODO: Install X11 window manager here.
}
