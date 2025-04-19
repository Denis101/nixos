rec {
  system.stateVersion = "24.11";
  wsl.enable = true;
  home-manager.users."denis" = {
    home.stateVersion = "24.11";
  };
}
