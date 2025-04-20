{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.profile.modules.home.bash;
in {
  config = lib.mkIf cfg.enable {
    programs.bash = {
      historyControl = ["ignoredups"];
      shellAliases = lib.literalExpression ''
        {
          ll = "ls -l";
          ".." = "cd ..";
          "-" = "cd -";
        }
      '';
    };
  };
}
