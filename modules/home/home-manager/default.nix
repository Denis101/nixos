{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profile;
in {
  config = lib.mkIf cfg.modules.home.home-manager.enable {
    home.username = cfg.username;
    home.homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/${cfg.username}"
      else "/home/${cfg.username}";
    programs.home-manager.enable = true;
  };
}
