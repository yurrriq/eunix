{
  description = "Rewriting UNIX tools for my own edification";

  inputs = {
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nmattia/naersk";
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, emacs-overlay, flake-utils, naersk, nixpkgs }: {
    overlay = final: prev:
      nixpkgs.lib.composeManyExtensions (builtins.attrValues self.overlays) final prev;

    overlays = {
      myEmacs = final: prev: {
        myEmacs = prev.emacsWithPackagesFromUsePackage {
          alwaysEnsure = true;
          config = ./emacs.el;
        };
      };

      xelatex-noweb = final: prev: {
        xelatex-noweb =
          prev.texlive.combine {
            inherit (prev) noweb;
            inherit (prev.texlive) scheme-small
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
          };
      };
    };
  } // flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      pkgs = import nixpkgs {
        overlays = [
          emacs-overlay.overlay
          self.overlay
        ];
        inherit system;
      };
    in
    {
      devShell = with pkgs; mkShell {
        inherit (self.defaultPackage.${system}) FONTCONFIG_FILE;

        buildInputs = self.defaultPackage.${system}.nativeBuildInputs ++ [
          cargo
          ccls
          clippy
          direnv
          myEmacs
          nix-direnv
          nixpkgs-fmt
          rnix-lsp
          rust-analyzer
          rustc
          rustfmt
        ];
      };

      defaultPackage = self.packages.${system}.eunix;

      packages = {
        eunix = with pkgs; stdenv.mkDerivation {
          pname = "eunix";
          version = builtins.readFile ./VERSION;
          # TODO: ignore Rust stuff
          src = nix-gitignore.gitignoreSource [ ] ./.;

          FONTCONFIG_FILE = makeFontsConf {
            fontDirectories = [
              (nerdfonts.override { fonts = [ "Iosevka" ]; })
            ];
          };

          nativeBuildInputs = [
            bats
            gcc
            indent
            noweb
            python3Packages.pygments
            which
            xelatex-noweb
          ];

          makeflags = [
            "prefix=${placeholder "out"}"
          ];

          preInstall = ''
            install -dm755 "$out/bin"
            install -dm755 "$out/docs"
          '';
        };

        reunix = naersk.lib.${system}.buildPackage {
          pname = "reunix";
          root = ./.;
          doCheck = true;
        };
      };
    }
  );
}
