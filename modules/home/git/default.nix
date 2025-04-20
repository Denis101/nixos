{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.profile.modules.home.git;
in {
  options.profile.modules.home.git = {
    enable = lib.mkEnableOption "git version control";
    name = lib.mkOption {
      type = lib.types.str;
      description = "Name to use for git commits";
      default = config.profile.fullName;
    };

    email = lib.mkOption {
      type = lib.types.str;
      description = "Email to use for git commits";
      default = config.profile.email;
    };

    defaultBranch = lib.mkOption {
      type = lib.types.str;
      description = "Default git branch";
      default = cfg.defaultBranch;
    };

    allowedSigners = lib.mkOption {
      type = lib.types.str;
      description = "git/allowed-signers text contents";
      default = cfg.allowedSigners;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.name;
      userEmail = cfg.email;
      extraConfig = {
        core.pager = "${pkgs.git}/share/git/contrib/diff-highlight/diff-highlight | less --no-init";
        interactive.difffilter = "${pkgs.git}/share/git/contrib/diff-highlight/diff-highlight";
        pager = {
          branch = "false";
        };
        pull = {
          ff = "only";
        };
        push = {
          autoSetupRemote = "true";
        };
        init = {
          defaultBranch = cfg.defaultBranch;
        };
        rebase = {
          autosquash = "true";
        };
        gpg = {
          format = "ssh";
          ssh.allowedSignersFile = "~/.config/git/allowed-signers";
        };
        ignores = [
          ".direnv/**"
          "result"
        ];
      };

      # xdg.configFile."git/allowed-signers".text = cfg.allowedSigners;
    };
  };
}
