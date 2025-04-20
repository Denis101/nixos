{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profile;
in {
  options.profile.modules.system.home-manager.enable = lib.mkEnableOption "home manager";

  config = lib.mkIf cfg.modules.system.home-manager.enable {
    environment.systemPackages = [
      pkgs.home-manager
    ];

    systemd.services."home-manager-${cfg.username}" = {
      serviceConfig.TimeoutStartSec = lib.mkForce "45m";
    };
  };
}
