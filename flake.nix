{
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # systems.url = "github:nix-systems/default";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      eachSystem =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system: f system nixpkgs.legacyPackages.${system}
        );

      beamVersion = "beam28Packages";
    in
    {
      packages = eachSystem (_system: _pkgs: { });

      devShells = eachSystem (
        _system: pkgs:
        let
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
          default = pkgs.mkShell {
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
            '';
          };
        }
      );
    };
}
