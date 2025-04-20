{ config, lib, ... }:

let
  inherit (config.profile.username) username;
  cfg = config.profile;
in {
  config = {
    # Allows declarative password setting
    # users.mutableUsers = lib.mkDefault false;

    users.users.${username} = {
      shell = pkgs.bash;
      isNormalUser = lib.mkDefault true;
    };
  };
}
