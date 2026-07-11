{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-gleam = {
      url = "github:arnarg/nix-gleam";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      beamVersion = "beamMinimal28Packages";
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        treefmt-nix.flakeModule
      ];

      systems = lib.systems.flakeExposed;

      perSystem =
        { system, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend (
            _: _: {
              inherit (inputs.nix-gleam.packages.${system}) buildGleamApplication;
            }
          );

          # Use only Chrome for E2E during local development
          playwright-browsers = pkgs.playwright-driver.browsers.override {
            withFirefox = false;
            withWebkit = false;
            withFfmpeg = false;
            # fontconfig_file = { fontDirectories = []; };
          };

          browserProgram = if pkgs.stdenv.targetPlatform.isLinux then "chrome" else "Chromium";
        in
        {
          packages = {
            # A self-contained package for deploying the entire app as a single
            # container image
            default = self.packages.${system}.server.overrideAttrs (old: {
              nativeBuildInuts = (old.nativeBuildInputs or [ ]) ++ [
                self.packages.${system}.client
              ];

              preBuild = ''
                cp -ar "${self.packages.${system}.client}/share/priv" .
              '';
            });

            server = pkgs.callPackage ./gleam.nix {
              inherit (pkgs.${beamVersion}) erlang rebar3;
              src = ./examples/mist;
            };

            client = pkgs.callPackage ./assets.nix {
              src = ./examples/mist;
            };

            docker-image = pkgs.dockerTools.buildImage {
              name = "gleam-inertia-demo";
              tag = "latest";

              copyToRoot = [
                self.packages.${system}.default
                pkgs.coreutils
              ];

              config = {
                Entrypoint = [
                  "${self.packages.${system}.default}/bin/demo_web"
                ];
                Cmd = [
                  "--bind"
                  "0.0.0.0"
                ];
              };

              diskSize = 1024;
              buildVMMemorySize = 512;
            };
          };

          treefmt.programs = {
            deadnix.enable = true;
            nixfmt.enable = true;
            zizmor.enable = true;
          };

          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.gleam
              pkgs.${beamVersion}.erlang
              pkgs.${beamVersion}.rebar3
              pkgs.nodejs
              pkgs.corepack
              pkgs.typescript-go
              pkgs.just
              playwright-browsers
            ]
            ++ lib.optional pkgs.stdenv.isLinux pkgs.inotify-tools
            ++ (lib.optionals pkgs.stdenv.isDarwin (
              with pkgs.darwin.apple_sdk.frameworks;
              [
                CoreFoundation
                CoreServices
              ]
            ));

            shellHook = ''
              browser_executable="$(find -L '${playwright-browsers}' -name ${browserProgram} -type f)"
              export PLAYWRIGHT_BROWSER_EXECUTABLE_PATH="''${browser_executable}"
              export PLAYWRIGHT_ONLY_CHROMIUM=1
            '';
          };

          checks = lib.filterAttrs (name: _: name != "docker-image") self.packages.${system};
        };
    };
}
