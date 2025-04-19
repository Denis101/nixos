{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.starship;
in {
  options.modules.starship = {
    enable = mkEnableOption "Starship module";
  };

  config = let
    stateVersion = "24.11";
  in mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pkgs.starship
    ];
  };
}
