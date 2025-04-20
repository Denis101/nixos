{ config, lib, pkgs, ... }:

let
  cfg = config.profile;
in {
  options.profile.modules.system.home-manager.enable = lib.mkEnableOption "home manager";

  config = lib.mkIf cfg.modules.system.home-manager.enable {
    home.username = cfg.username;
    home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${cfg.username}" else "/home/${cfg.username}";

    programs.home-manager.enable = true;
  };
}
