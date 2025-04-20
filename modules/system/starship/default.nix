{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.profile.modules.system.starship;
in {
  options.profile.modules.system.starship = {
    enable = mkEnableOption "Starship module";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pkgs.starship
    ];
  };
}
