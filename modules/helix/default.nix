{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.helix;
in {
  options.modules.helix = {
    enable = mkEnableOption "Helix module";
  };

  config = let
    stateVersion = "24.11";
  in mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pkgs.helix
    ];
  };
}
