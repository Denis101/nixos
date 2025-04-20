{ config, lib, ... }:

let
  inherit (config.profile.username) username;
  cfg = config.profile.modules.system.home-manager;
in {
  options.profile.modules.system.home-manager.enable = lib.mkEnableOPtion "home manager";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.home-manager
    ];

    systemd.services."home-manager-${username}" = {
      serviceConfig.TimeoutStartSec = lib.mkForce "45m";
    };
  };
}
