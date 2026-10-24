{ pkgs, ... }:

let

  pname = "minecarrft";
  version = "6.9";

  gmAppImage = pkgs.fetchurl {
    url = "https://appimage-proxy.remin-p.workers.dev/";
    sha256 = "7559471672cbb36fb6e2159d894a96d9a56da563770dc74b982d84927ee56be0";
  };

  gmPackage = pkgs.appimageTools.wrapType2 {
    inherit pname version;
    src = gmAppImage;
    # extraPkgs = pkgs: with pkgs; [ libgbm ];
  };
in
{
  environment.systemPackages = [ gmPackage ];
}
