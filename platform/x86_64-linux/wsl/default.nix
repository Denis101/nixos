rec {
  profile = {
    username = "denis";
    fullName = "Denis Craig";
    email = "admin@deniscraig.com";
    modules = {
      system.wsl.enable = true;
      system.helix.enable = true;
      system.starship.enable = true;
      system.tmux.enable = true;
      home.git.enable = true;
      # home-manager.enable = true;
    };
  };

  system.stateVersion = "24.11";
  home-manager.users.${profile.username} = {
    home.stateVersion = "24.11";
  };
}
