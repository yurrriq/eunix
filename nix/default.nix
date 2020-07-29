let
  sources = import ./sources.nix;
in

import sources.nixpkgs {
  overlays = [
    (
      self: super: {
        inherit (import sources.niv { pkgs = super; }) niv;
        nix-gitignore = import sources."gitignore.nix" {};
        xelatex-noweb = (
          super.texlive.combine {
            inherit (super) noweb;
            inherit (super.texlive) scheme-small
              catchfile
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
              xstring
              ;
          }
        );
        eunix = import ../. {};
      }
    )
  ];
}
