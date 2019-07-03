{ nur ? import <nur> {} }:

let
  srcDef = builtins.fromJSON (builtins.readFile ./nixpkgs.json);

  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/${srcDef.owner}/${srcDef.repo}/tarball/${srcDef.rev}";
    inherit (srcDef) sha256;
  };

in

# FIXME: import nixpkgs {
import <nixpkgs> {
  overlays = [
    (import <nur> {}).repos.yurrriq.overlays.nur
    (self: super: {
      xelatex-noweb = (super.texlive.combine {
        inherit (super) noweb;
        inherit (super.texlive) scheme-small
          datetime
          dirtytalk
          fmtcount
          framed
          fvextra
          hardwrap
          ifplatform
          latexmk
          minted
          titlesec
          todonotes
          tufte-latex
          xetex
          xstring;
      });
    })
  ];
}
