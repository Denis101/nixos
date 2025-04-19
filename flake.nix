{
  description = "Global development environment";

  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*";
    flake-utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.*";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2411.*";
    wsl.url = "github:nix-community/NixOS-WSL";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, ... }@inputs:
    let
      globals = rec {
        user = "denis";
        fullName = "Denis Craig";
        gitName = fullName;
        gitEmail = "admin@deniscraig.com";
      };

      overlays = [];
    in rec {
      schemas = inputs.flake-schemas.schemas;
      lib = import ./lib.nix inputs;

      nixosConfigurations = builtins.mapAttrs (
        system: platforms:
        builtins.mapAttrs (
          name: module:
          lib.buildNixos {
            inherit system module;
            specialArgs = { inherit globals; };
          }
        ) platforms
      ) lib.linuxPlatforms;

      darwinConfigurations = builtins.mapAttrs (
        system: platforms:
        builtins.mapAttrs (
          name: module:
          lib.buildDarwin {
            inherit system module;
            specialArgs = { inherit globals; };
          }
        ) platforms
      ) lib.linuxPlatforms;

      homeConfigurations = builtins.mapAttrs (
        system: platforms:
        builtins.mapAttrs (
          name: module:
          lib.buildHome {
            inherit system module;
            specialArgs = { inherit globals; };
          }
        ) platforms
      ) lib.linuxPlatforms;

      devShells = inputs.flake-utils.lib.eachDefaultSystem (
        system:
          let pkgs = import nixpkgs { inherit system overlays; };
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

      formatter = inputs.flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            inherit (lib) overlays;
          };
        in
        pkgs.nixfmt-rfc-style
      );
    };
}
