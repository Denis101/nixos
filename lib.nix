inputs:

let
  lib = inputs.nixpkgs.lib;
  flakeUtils = inputs.flake-utils.lib;
in
lib // rec {
  supportedSystems = builtins.filter (system: builtins.pathExists ./platform/${system}) flakeUtils.defaultSystems;
  linuxSystems = builtins.filter (lib.hasSuffix "linux") supportedSystems;
  darwinSystems = builtins.filter (lib.hasSuffix "darwin") supportedSystems;

  eachSupportedSystem = flakeUtils.eachSystem supportedSystems;
  eachLinuxSystem = flakeUtils.eachSystem linuxSystems;
  eachDarwinSystem = flakeUtils.eachSystem darwinSystems;

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

  supportedPlatformSystems = eachSupportedSystem (system: defaultFilesAttrset ./platform/${system});
  linuxPlatformSystems = eachLinuxSystem (system: defaultFilesAttrset ./platform/${system});
  darwinPlatformSystems = eachDarwinSystem (system: defaultFilesAttrset ./platform/${system});

  pkgsBySystem = eachSupportedSystem (
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
      { imports = ./modules/profile; }
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
      { imports = ./modules/profile; }
      { imports = (defaultFilesInDir ./modules/home); }
      module
    ];
    extraSpecialArgs = {
      inherit colorscheme;
    } // specialArgs;
  };
}
