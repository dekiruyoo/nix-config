# ly-dm and relevant packages.
{ pkgs, durdraw, ... }:
{
  environment.systemPackages = [
    durdraw.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "matrix";
      clock = "%c";
      bigclock = true;
    };
  };
}
