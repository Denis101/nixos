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
      ) lib.linuxPlatformSystems;

      darwinConfigurations = builtins.mapAttrs (
        system: platforms:
        builtins.mapAttrs (
          name: module:
          lib.buildDarwin {
            inherit system module;
            specialArgs = { inherit globals; };
          }
        ) platforms
      ) lib.darwinPlatformSystems;

      homeModules = builtins.mapAttrs (
        system: platforms:
        builtins.mapAttrs (
          name: module: (builtins.head (lib.attrsToList module.home-manager.users)).value
        ) platforms
      ) lib.supportedPlatformSystems;

      homeConfigurations = builtins.mapAttrs (
        system: platforms:
        builtins.mapAttrs (
          name: module:
          lib.buildHome {
            inherit system module;
            specialArgs = { inherit globals; };
          }
        ) platforms
      ) homeModules;

      # packages = lib.supportedSystemAttrs (
      #   system:
      #   {
      #     nixosConfigurations = nixosConfigurations.${system};
      #     darwinConfigurations = darwinConfigurations.${system};
      #     homeConfigurations = homeConfigurations.${system};
      #   }
      # );

      devShells = lib.supportedSystemAttrs (
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

      formatter = lib.supportedSystemAttrs (
        system:
        let pkgs = import nixpkgs { inherit system overlays; };
        in
        pkgs.nixfmt-rfc-style
      );
    };
}
