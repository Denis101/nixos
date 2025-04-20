inputs:

let
  lib = inputs.nixpkgs.lib;
  flakeUtils = inputs.flake-utils.lib;
in
lib // rec {
  supportedSystems = builtins.filter (system: builtins.pathExists ./platform/${system}) flakeUtils.defaultSystems;

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

  flattenAttrset = attrs: builtins.foldl' lib.mergeAttrs { } (builtins.attrValues attrs);

  linuxSystems = builtins.filter (lib.hasSuffix "linux") supportedSystems;
  darwinSystems = builtins.filter (lib.hasSuffix "darwin") supportedSystems;

  forAllSystems = lib.genAttrs supportedSystems;

  platforms = forAllSystems (system: defaultFilesAttrset ./platform/${system});
  linuxPlatforms = lib.filterAttrs (name: value: builtins.elem name linuxSystems) platforms;
  darwinPlatforms = lib.filterAttrs (name: value: builtins.elem name darwinSystems) platforms;

  pkgsBySystem = forAllSystems (
    system:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    }
  );

  colorscheme = defaultFilesAttrset ./colorscheme;

  homeModule = {
    home-manager = {
      useGlobalPkgs = lib.mkDefault true;
      useUserPackages = lib.mkDefault true;
    };
  };

  buildNixos = { system, module, specialArgs }: inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    pkgs = pkgsBySystem.${system};
    modules = [
      inputs.home-manager.nixosModules.home-manager
      inputs.wsl.nixosModules.wsl
      { imports = [./modules/profile]; }
      { imports = (defaultFilesInDir ./modules/system); }
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
      { imports = [./modules/profile]; }
      { imports = (defaultFilesInDir ./modules/home); }
      module
    ];
    extraSpecialArgs = {
      inherit colorscheme;
    } // specialArgs;
  };
}
