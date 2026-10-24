{ pkgs, ... }:

let

  pname = "wabba";
  version = "6.7";

  wabbaAppImage = pkgs.fetchurl {
    url = "https://github.com/Omni-guides/Jackify/releases/download/v0.8.1.2/Jackify.AppImage";
    sha256 = "a56f700e63d172028265c3df87c22b7f143708085831d9825314ffcd34903b28";
  };

  wabbaPackage = pkgs.appimageTools.wrapType2 {
    inherit pname version;
    src = wabbaAppImage;
    extraPkgs = pkgs: with pkgs; [ zstd ];
  };
in
{
  environment.systemPackages = [ wabbaPackage ];
}
