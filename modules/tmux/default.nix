{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.modules.tmux;
in {
  options.modules.tmux = {
    enable = mkEnableOption "tmux module";
  };

  config = let
    stateVersion = "24.11";
  in mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pkgs.tmux
    ];
  };
}
