inputs:

let
  lib = inputs.nixpkgs.lib;
  flakeUtils = inputs.flake-utils.lib;
in
lib // rec {
  linuxSystems = builtins.filter (lib.hasSuffix "linux") flakeUtils.defaultSystems;
  darwinSystems = builtins.filter (lib.hasSuffix "darwin") flakeUtils.defaultSystems;

  defaultFilesInDir =
    directory:
    lib.pipe (lib.filesystem.listFilesRecursive directory) [
      (builtins.filter (name: lib.hasSuffix "default.nix" name))
    ];

  defaultFilesAttrset =
    directory:
    lib.pipe (defaultFilesInDir directory) [
      (map (file: {
        name = builtins.baseNameOf (builtins.dirOf file);
        value = import file;
      }))
      (builtins.listToAttrs)
    ];

  platforms = flakeUtils.eachDefaultSystem (system: defaultFilesAttrset ./platform/${system});
  linuxPlatforms = lib.filterAttrs (name: value: builtins.elem name linuxSystems) platforms;
  darwinPlatforms = lib.filterAttrs (name: value: builtins.elem name darwinSystems) platforms;

  pkgsBySystem = flakeUtils.eachDefaultSystem (
    system:
    import inputs.nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    }
  );

  buildNixos = { system, module, specialArgs }: inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    pkgs = pkgsBySystem.${system};
    modules = [
      inputs.home-manager.nixosModules.home-manager
      inputs.wsl.nixosModules.wsl
      module
      {
        home-manager = {
          extraSpecialArgs = {
            inherit colorscheme;
          } // specialArgs;
        } // homeModule.home-manager;
      }
    ];
  };

  buildDarwin = { system, module, specialArgs }: inputs.darwin.lib.darwinSystem {
    inherit system specialArgs;
    modules = [
      inputs.home-manager.darwinModules.home-manager
      inputs.mac-app-util.darwinModules.default
      {
        nixpkgs.pkgs = pkgsBySystem.${system};
      }
      module
      {
        home-manager = {
          extraSpecialArgs = {
            inherit colorscheme;
          } // specialArgs;
        } // homeModule.home-manager;
      }
    ];
  };

  buildHome = { system, module, specialArgs }: inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = pkgsBySystem.${system};
    modules = [
      module
    ];
    extraSpecialArgs = {
      inherit colorscheme;
    } // specialArgs;
  };
}
