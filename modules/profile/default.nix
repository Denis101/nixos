{ inputs, lib, config, pkgs, ... }: {
  options.profile = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "Primary username for the system";
    };

    fullName = lib.mkOption {
      type = lib.types.str;
      description = "Full name for the primary user of the system";
    };

    email = lib.mkOption {
      type = lib.types.str;
      description = "Email for the primary user of the system";
    };

    modules = {
      system = {
        wsl = {
          enable = lib.mkOption {
            type = lib.types.bool;
            descriptoin = "Is windows subsystem for linux enabled?";
          };
        };
      };

      home = {
        git = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = "Is git enabled?";
          };

          defaultBranch = lib.mkOption {
            type = lib.types.str;
            description = "Default git branch";
            default = "main";
          };

          allowedSigners = lib.mkOption {
            type = lib.types.str;
            description = "git/allowed-signers text contents"
          };
        };
      };

      helix = {
        enable = lib.mkOption {
          type = lib.types.bool;
          description = "Is helix editor enabled?";
        };
      };

      home-manager = {
        enable = lib.mkOption {
          type = lib.types.bool;
          description = "Is home-manager enabled?";
        };
      };

      starship = {
        enable = lib.mkOption {
          type = lib.types.bool;
          description = "Is starship shell enabled?";
        };
      };

      tmux = {
        enable = lib.mkOption {
          type = lib.types.bool;
          description = "Is tmux enabled?";
        };
      };
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = "nix-command flakes";
      nix-path = config.nix.nixPath;
    };

    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  networking.hostName = "nixos";
  system.stateVersion = "24.11";
}
