{
  description = "Global development environment";

  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
    flake-utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.*";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2411.*";
    wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";
      ref = "release-24.11";
    };
  };
  outputs = { self, nixpkgs, ... }@inputs: rec {
    inherit (self) outputs;
    schemas = inputs.flake-schemas.schemas;
    lib = import ./lib.nix inputs;

    nixosConfigurations = lib.flattenAttrset (
      builtins.mapAttrs (
        system: platforms:
        builtins.mapAttrs (
          name: module:
          lib.buildNixos {
            inherit system module;
            specialArgs = { inherit inputs outputs; };
          }
        ) platforms
      ) lib.linuxPlatforms
    );

    darwinConfigurations = lib.flattenAttrset (
      builtins.mapAttrs (
        system: platforms:
        builtins.mapAttrs (
          name: module:
          lib.buildDarwin {
            inherit system module;
            specialArgs = { inherit inputs outputs; };
          }
        ) platforms
      ) lib.darwinPlatforms
    );

    homeModules = builtins.mapAttrs (
      system: platforms:
      builtins.mapAttrs (
        name: module: (builtins.head (lib.attrsToList module.home-manager.users)).value
      ) platforms
    ) lib.platforms;

    homeConfigurations = builtins.mapAttrs (
      system: platforms:
      builtins.mapAttrs (
        name: module:
        lib.buildHome {
          inherit system module;
          specialArgs = { inherit inputs outputs; };
        }
      ) platforms
    ) homeModules;

    packages = lib.forAllSystems (
      system:
      {
        inherit nixosConfigurations darwinConfigurations;
        homeConfigurations = homeConfigurations.${system};
      }
    );

    devShells = lib.forAllSystems (
      system:
        let pkgs = import nixpkgs { inherit system; };
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

    formatter = lib.forAllSystems (
      system:
      let pkgs = import nixpkgs { inherit system; };
      in
      pkgs.nixfmt-rfc-style
    );
  };
}
