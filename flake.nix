{
  description = "template";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs";
    purescript-overlay = {
      url = "github:thomashoneyman/purescript-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem = { config, inputs', pkgs, system, ... }: {
        _module.args.pkgs =
          import inputs.nixpkgs {
            localSystem = system;
            overlays = [
              inputs.purescript-overlay.overlays.default
            ];
          };

        packages =
          let
            workspace = pkgs.purix.buildSpagoLock { src = ./.; };
          in
          {
            default = config.packages.template;

            # TODO: Bundle into a module or an executable
            template = workspace.template;
          };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.esbuild
            pkgs.nodejs
            pkgs.purs-backend-es-unstable
            pkgs.purs-tidy-unstable
            pkgs.purs-unstable
            pkgs.spago-unstable
          ];
        };
      };
    };
}
