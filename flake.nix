{
  description = "Rewriting UNIX tools for my own edification";

  inputs = {
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    fenix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/fenix";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    naersk.url = "github:nmattia/naersk";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = inputs@{ flake-parts, nixpkgs, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        overlays = {
          default = let inherit (nixpkgs) lib; in
            lib.composeManyExtensions
              (lib.attrValues
                (lib.filterAttrs (name: _: name != "default") self.overlays));

          myEmacs = _final: prev: {
            myEmacs = prev.emacsWithPackagesFromUsePackage {
              alwaysEnsure = true;
              config = ./emacs.el;
            };
          };

          xelatex-noweb = _final: prev: {
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
      };

      imports = [
        inputs.pre-commit-hooks-nix.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
      ];

      perSystem = { config, lib, pkgs, self', system, ... }: {
        _module.args.pkgs = import nixpkgs {
          overlays = [
            inputs.emacs-overlay.overlay
            inputs.fenix.overlays.default
            self.overlays.default
          ];
          inherit system;
        };

        devShells.default = pkgs.mkShell {
          inherit (self'.packages.default) FONTCONFIG_FILE;
          RUST_BACKTRACE = 1;

          inputsFrom = [
            config.pre-commit.devShell
            self'.packages.default
          ];

          nativeBuildInputs = with pkgs; [
            ccls
            direnv
            (
              fenix.complete.withComponents [
                "cargo"
                "clippy"
                "rust-src"
                "rustc"
                "rustfmt"
              ]
            )
            myEmacs
            nix-direnv
            nixpkgs-fmt
            rnix-lsp
            rust-analyzer-nightly
          ];
        };

        packages = {
          default = self'.packages.eunix;

          eunix = with pkgs; stdenv.mkDerivation {
            pname = "eunix";
            version = builtins.readFile ./VERSION;
            # TODO: ignore Rust stuff
            src = nix-gitignore.gitignoreSource [ ] ./.;

            FONTCONFIG_FILE = pkgs.makeFontsConf {
              fontDirectories = [
                (pkgs.nerdfonts.override { fonts = [ "Iosevka" ]; })
              ];
            };

            nativeBuildInputs = with pkgs; [
              bats
              gcc
              noweb
              python3Packages.pygments
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
          };

          reunix = inputs.naersk.lib.${system}.buildPackage {
            pname = "reunix";
            root = ./.;
            doCheck = true;
          };
        };

        pre-commit.settings.hooks = {
          convco.enable = true;
          editorconfig-checker.enable = true;
          make-src = {
            description = "Ensure literate sources are tangled";
            enable = true;
            entry =
              let
                make-src = pkgs.writeShellApplication {
                  name = "make-src";
                  runtimeInputs = with pkgs; [
                    noweb
                  ];
                  text = "make -B src";
                };
              in
              "${make-src}/bin/make-src";
            files = "\\.nw$";
          };
          treefmt.enable = true;
        };

        treefmt = {
          projectRootFile = ./flake.nix;
          programs = {
            clang-format.enable = true;
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            rustfmt = {
              enable = true;
              package = pkgs.fenix.complete.rustfmt;
            };
          };
          settings.formatter = {
            clang-format.options = [
              "-style=file"
            ];
            rustfmt.options = lib.mkForce [
              "--edition"
              "2021"
            ];
          };
        };
      };
    };
}
