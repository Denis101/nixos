{ config, lib, ... }:

let
  inherit (config.profile.username) username;
  cfg = config.profile.modules.system.wsl;
in {
  options.profile.modules.system.wsl.enable = lib.mkEnableOption "WSL settings";

  config = lib.mkIf cfg.enable {
    wsl = {
      enable = true;
      defaultUser = lib.mkDefault username;
      startMenuLaunchers = lib.mkDefault true;
      nativeSystemd = lib.mkDefault true;
      interop.includePath = lib.mkDefault false;
      wslConf = {
        automount.root = lib.mkDefault "/mnt";
        network.generateResolvConf = lib.mkDefault true;
      }
    }
  };
}
