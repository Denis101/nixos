{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.profile.modules.home.tmux;
in {
  config = lib.mkIf cfg.enable {
    programs.bash.bashrcExtra = builtins.readFromFile ./config/.bashrc;

    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      historyLimit = 8192;
      shortcut = "a";
      mouse = true;
      clock24 = true;
      extraConfig = builtins.readFromFile ./config/.tmux.conf;
    };
  };
}
