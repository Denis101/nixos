{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.profile.modules.system.tmux;
in {
  options.profile.modules.system.tmux = {
    enable = mkEnableOption "tmux module";
  };

  config = let
    stateVersion = "24.11";
  in
    mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        pkgs.tmux
      ];
    };
}
