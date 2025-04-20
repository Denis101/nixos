rec {
  profile = {
    username = "denis";
    fullName = "Denis Craig";
    email = "admin@deniscraig.com";
    modules = {
      helix.enable = true;
      home-manager.enable = true;
      starship.enable = true;
      tmux.enable = true;
      wsl.enable = true;
    };
  };

  system.stateVersion = "24.11";
  home-manager.users.${profile.username} = {
    home.stateVersion = "24.11";
  };
}
