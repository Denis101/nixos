{ config, lib, pkgs, ... }:

let
  cfg = config.profile;
in {
  config = {
    # Allows declarative password setting
    # users.mutableUsers = lib.mkDefault false;

    users.users.${cfg.username} = {
      shell = pkgs.bash;
      isNormalUser = lib.mkDefault true;
    };

    wsl.enable = lib.mkDefault false;
  };
}
