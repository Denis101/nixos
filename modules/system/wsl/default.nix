{
  config,
  lib,
  ...
}: let
  cfg = config.profile;
in {
  options.profile.modules.system.wsl.enable = lib.mkEnableOption "WSL settings";

  config = lib.mkIf cfg.modules.system.wsl.enable {
    wsl = {
      enable = true;
      defaultUser = lib.mkDefault cfg.username;
      startMenuLaunchers = lib.mkDefault true;
      interop.includePath = lib.mkDefault false;
      wslConf = {
        automount.root = lib.mkDefault "/mnt";
        network.generateResolvConf = lib.mkDefault true;
      };
    };
  };
}
