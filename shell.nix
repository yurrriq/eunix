{
  nur ? import <nur> {},
  pkgs ? import ./nix/nixpkgs.nix { inherit nur; }
}:

pkgs.mkShell {
  FONTCONFIG_FILE = pkgs.makeFontsConf {
    fontDirectories = [ pkgs.iosevka ];
  };
  buildInputs = [
    pkgs.nix-prefetch-github
  ] ++ (import ./. { inherit pkgs; }).buildInputs;
}
