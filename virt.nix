{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome-boxes
    qemu_full
  ];

  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  
  users.users."muffy" = {
    extraGroups = [ "libvirtd" ];
  };

  # dconf.settings."org/virt-manager/virt-manager/connections" = {
  #   autoconnect = [ "qemu:///system" ];
  #   uris = [ "qemu:///system" ];
  # };
}
