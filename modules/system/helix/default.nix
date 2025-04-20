{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.profile.modules.system.helix;
in {
  options.profile.modules.system.helix = {
    enable = mkEnableOption "Helix module";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pkgs.helix
    ];
  };
}
