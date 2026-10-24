{ config, pkgs, ... }:

{
  imports = [ 
  ../swaybar.nix # As tested, sway works 90% fine with legacy nvidia drivers. 
  ../terminal.nix
  ../gamer.nix
  ];
  # GPU: GT 1030, needs the legacy driver branch.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580; # Compatible with GT 1030.
  };

  # Move resolution change flicker by loading the kernel modules earlier.
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" "nvidia_uvm" ];
  boot.kernelParams = [ "nosgx" "quiet" ];
  boot.plymouth = {
    enable = true;
    theme = "spinner";
  };

  # Use last kernel that's compatible with GT 1030.
  boot.kernelPackages = pkgs.linuxPackages_6_18; # TODO: You might as well change this to LTS.

  # Disk encryption — specific to this machine's physical disk.
  boot.initrd.luks.devices."luks-9e5f5584-7871-469f-88a1-91190fb31789".device =
    "/dev/disk/by-uuid/9e5f5584-7871-469f-88a1-91190fb31789";
  
  networking.hostName = "t1me"; # It's muffin time!

  services.libinput.enable = false; # No touchpad available.

  networking.hosts = {
    "127.0.0.1" = [ "www.youtube.com" "yewtu.be" "redirect.invidious.io" ]; # Browsing this website makes me hate myself. My flatmate would say this is an extreme (as in, drug addict level), but i feel like it has gotten to that point. 
  };
}
