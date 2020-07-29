{ pkgs ? import ./nix }:

pkgs.mkShell {
  inherit (pkgs.eunix) FONTCONFIG_FILE;
  buildInputs = with pkgs; (
    [
      niv
      nixpkgs-fmt
    ] ++ eunix.nativeBuildInputs
  );
}
