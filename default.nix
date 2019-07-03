{
  nur ? import <nur> {},
  pkgs ? import ./nix/nixpkgs.nix { inherit nur; },
  src ? pkgs.nix-gitignore.gitignoreRecursiveSource [".git/"] ./.
}:

pkgs.stdenv.mkDerivation rec {
  pname = "eunix";
  version = "0.0.1";
  inherit src;

  FONTCONFIG_FILE = pkgs.makeFontsConf {
    fontDirectories = [ pkgs.iosevka ];
  };

  buildInputs = with pkgs; [
    gcc
    indent
    iosevka
    noweb
    python36Packages.pygments
    which
    xelatex-noweb
  ];

  postInstall = ''
    install -dm755 "$out/bin"
    cp bin/* "$_/"
    install -dm755 "$out/docs"
    cp docs/*.pdf "$_/"
  '';
}
