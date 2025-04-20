{
  description = "NixOS configurations, modules, and devShells.";

  inputs = {
    flake-schemas = {
      type = "github";
      owner = "DeterminateSystems";
      repo = "flake-schemas";
      ref = "refs/tags/v0.1.5";
    };
    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "refs/tags/v1.0.0";
    };
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "24.11";
    };
    nix-fmt = {
      type = "github";
      owner = "Denis101";
      repo = "flake-nix-fmt";
      ref = "0.0.2";
      inputs.flake-schemas.follows = "flake-schemas";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-utils = {
      type = "github";
      owner = "Denis101";
      repo = "flake-nix-utils";
      ref = "0.0.1";
      inputs.flake-schemas.follows = "flake-schemas";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-fmt.follows = "nix-fmt";
    };
    wsl = {
      type = "github";
      owner = "nix-community";
      repo = "NixOS-WSL";
      ref = "2411.6.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      type = "github";
      owner = "nix-darwin";
      repo = "nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      type = "github";
      owner = "hraban";
      repo = "mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nix-fmt,
    nix-utils,
    ...
  } @ inputs: rec {
    inherit (self) outputs;
    schemas = inputs.flake-schemas.schemas;
    checks = nix-fmt.checks;
    formatter = nix-fmt.formatter;

    nixosConfigurations = nix-utils.lib.flattenAttrset (
      builtins.mapAttrs (
        system: platforms:
          builtins.mapAttrs (
            name: module:
              nix-utils.lib.buildNixos {
                inherit system module;
                specialArgs = {inherit inputs outputs;};
              }
          )
          platforms
      )
      nix-utils.lib.linuxPlatforms
    );

    darwinConfigurations = nix-utils.lib.flattenAttrset (
      builtins.mapAttrs (
        system: platforms:
          builtins.mapAttrs (
            name: module:
              nix-utils.lib.buildDarwin {
                inherit system module;
                specialArgs = {inherit inputs outputs;};
              }
          )
          platforms
      )
      nix-utils.lib.darwinPlatforms
    );

    homeModules =
      builtins.mapAttrs (
        system: platforms:
          builtins.mapAttrs (
            name: module: (builtins.head (nixpkgs.lib.attrsToList module.home-manager.users)).value
          )
          platforms
      )
      nix-utils.lib.platforms;

    homeConfigurations =
      builtins.mapAttrs (
        system: platforms:
          builtins.mapAttrs (
            name: module:
              nix-utils.lib.buildHome {
                inherit system module;
                specialArgs = {inherit inputs outputs;};
              }
          )
          platforms
      )
      homeModules;

    packages = nix-utils.lib.forAllSystems (
      system: {
        inherit nixosConfigurations darwinConfigurations;
        homeConfigurations = homeConfigurations.${system};
      }
    );

    devShells = nix-utils.lib.forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            nixfmt
            shfmt
            shellcheck
          ];
        };
      }
    );
  };
}
