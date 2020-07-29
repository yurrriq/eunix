{ pkgs ? import ./nix
, src ? pkgs.nix-gitignore.gitignoreSource ./.
}:

pkgs.stdenv.mkDerivation rec {
  pname = "eunix";
  version = builtins.readFile ./VERSION;
  inherit src;

  FONTCONFIG_FILE = pkgs.makeFontsConf {
    fontDirectories = [ pkgs.iosevka ];
  };

  nativeBuildInputs = with pkgs; [
    bats
    gcc
    indent
    iosevka
    noweb
    python36Packages.pygments
    which
    xelatex-noweb
  ];

  makeFlags = [
    "prefix=${placeholder "out"}"
  ];

  preInstall = ''
    install -dm755 "$out/bin"
    install -dm755 "$out/docs"
  '';
}
