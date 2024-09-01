{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
    fenix-overlay = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, utils, crane, fenix-overlay }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ fenix-overlay.overlays.default ];
        };

        craneLib = crane.mkLib pkgs;

        darwinBuildInputs = with pkgs; [
            darwin.CF
            darwin.Security
            darwin.apple_sdk.frameworks.AppKit
            darwin.apple_sdk.frameworks.CoreMedia
            darwin.apple_sdk.frameworks.CoreVideo
            darwin.apple_sdk.frameworks.Metal
            darwin.apple_sdk.frameworks.System
            darwin.apple_sdk.frameworks.VideoToolbox

            # Provides an xcode compatible build env
            xcbuild

            # Runs scripts to ensure darwin framework headers are picked up
            rustPlatform.bindgenHook
        ];

        nativeBuildInputs = with pkgs; [
            pkg-config
        ] ++ lib.optional stdenv.isDarwin darwinBuildInputs;

        buildInputs = with pkgs; [
            openssl
            libiconv
            rustfmt
            curl
        ] ++ lib.optional stdenv.isDarwin darwinBuildInputs;
      in
      rec {
        packages = {
          default = craneLib.buildPackage {
              src = craneLib.cleanCargoSource ./.;
              strictDeps = true;
              inherit nativeBuildInputs;
              inherit buildInputs;
          };
        };

        apps = {
            default = utils.lib.mkApp {
                drv = packages.default;
            };
        };

        devShells = {
            default = craneLib.devShell {
                inputsFrom = [ packages.default ];
                packages = with pkgs; [
                    rust-analyzer
                ];
            };
        };
      }
    );
}
