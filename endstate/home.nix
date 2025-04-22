{pkgs, ...}: let
  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = pkgs.writeShellScriptBin "manpager" ''
    cat "$1" | col -bx | bat --language man --style plain
  '';
in {
  home.username = "denis";
  home.homeDirectory = "/home/denis";
  home.stateVersion = "24.11";

  home.packages = [
    pkgs.alejandra
    pkgs.bat
    pkgs.direnv
    pkgs.fzf
    pkgs.gh
    pkgs.git
    pkgs.gnupg
    pkgs.go
    pkgs.htop
    pkgs.helix
    pkgs.jq
    pkgs.nixd
    pkgs.nnn
    pkgs.pinentry-curses
    pkgs.sesh
    pkgs.starship
    pkgs.tmux
    pkgs.tmuxinator
    pkgs.tree
    pkgs.watch
    pkgs.zoxide
    pkgs.zsh
  ];

  home.file.".zlogin_extra" = {
    source = ./.zlogin_extra;
  };

  home.file.".zlogout_extra" = {
    source = ./.zlogout_extra;
  };

  home.file.".zsh_extra" = {
    source = ./.zsh_extra;
  };

  home.file.".config/tmuxinator/test.yml" = {
    source = ./test.yml;
  };

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    # This doesn't work currently for some reason
    LS_COLORS = "ex=37:di=36:tw=36:ow=36:";
    PAGER = "less -FirSwX";
    MANPAGER = "${manpager}/bin/manpager";
  };

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    config = {
      strict_env = true;
      whitelist = {
        prefix = [
          "/home/denis/git"
        ];

        exact = ["$HOME/.envrc"];
      };
    };
  };

  programs.zsh = {
    enable = true;

    history = {
      extended = true;
      size = 8192;
    };

    shellAliases = {
      ll = "ls -lah";
      nix-shell = "nix-shell --run $SHELL";
      nix-develop = "nix develop -c $SHELL";
      seshls = "sesh list";
      seshfz = "sesh list | fzf";
      seshcn = "sesh connect $(sesh list | fzf)";
    };

    # Replace with top-level plugins?
    zplug = {
      enable = true;
      plugins = [
        {name = "zsh-users/zsh-autosuggestions";}
        {name = "zsh-users/zsh-syntax-highlighting";}
        {name = "zsh-users/zsh-completions";}
        {name = "zsh-users/zsh-history-substring-search";}
      ];
    };

    loginExtra = ''
      source ~/.zlogin_extra
    '';

    logoutExtra = ''
      source ~/.zlogout_extra
    '';

    initExtra = ''
      source ~/.zsh_extra
    '';
  };

  programs.git = {
    enable = true;
    userName = "denis";
    userEmail = "admin@deniscraig.com";
    aliases = {
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
    };
    extraConfig = {
      core.pager = "${pkgs.git}/share/git/contrib/diff-highlight/diff-highlight | less --no-init";
      interactive.difffilter = "${pkgs.git}/share/git/contrib/diff-highlight/diff-highlight";
      pager = {
        branch = "false";
      };
      pull = {
        ff = "only";
      };
      push = {
        autoSetupRemote = "true";
      };
      init = {
        defaultBranch = "main";
      };
      rebase = {
        autosquash = "true";
      };
      commit = {
        gpgSign = true;
      };
      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = "~/.config/git/allowed-signers";
      };
    };
  };

  programs.gpg = {
    enable = true;
  };

  programs.starship = {
    #          
    # #191d24
    # palette: dark blue -> light blue
    # #011f4b
    # #03396c
    # #005b96
    # #6497b1
    # #b3cde0

    enable = true;
    settings = {
      format = "($os$battery$time[░▒▓](#191d24)$directory[▓▒░](#191d24)$git_branch$git_commit$git_state$git_status$fill$nix_shell$container$kubernetes$docker_context$c$cmake$dotnet$helm$java$kotlin$golang$gradle$lua$nodejs$python$rust$scala$terraform$zig$aws$gcloud$azure\n)$cmd_duration$status$hostname$localip$shlvl$shell$env_var$jobs$sudo$username$character";
      right_format = "$memory_usage$custom";
      # scan_timeout = 10;
      # command_timeout = 100;
      add_newline = true;
      continuation_prompt = "[▸▹ ](dimmed white)";

      fill = {
        symbol = " ";
      };

      character = {
        format = "$symbol ";
        success_symbol = "[❯](cyan)[❯](bold blue)";
        error_symbol = "[❯](purple)[❯](bold blue)";
      };

      sudo = {
        format = "[$symbol]($style)";
        style = "bold italic bright-purple";
        symbol = "⋈┈";
        disabled = false;
      };

      username = {
        style_user = "bright-yellow bold italic";
        style_root = "purple bold italic";
        format = "[⭘ $user]($style) ";
        disabled = false;
        show_always = false;
      };

      directory = {
        home_symbol = "⌂";
        truncation_symbol = " ⋯/";
        read_only = "◈";
        read_only_style = "fg:red bg:#191d24";
        style = "italic fg:#005b96 bg:#191d24";
        format = "[ $path]($style)[$read_only ]($read_only_style)";
        repo_root_style = "fg:#6497b1 bg:#191d24";
        before_repo_root_style = "italic fg:#005b96 bg:#191d24";
        repo_root_format = "[ $before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style)[$read_only ]($read_only_style)";

        # fish_style_pwd_dir_length = 1;
      };

      cmd_duration = {
        format = "[◄ $duration ](italic white)";
      };

      jobs = {
        format = "[$symbol$number]($style) ";
        style = "white";
        symbol = "[▶](blue italic)";
      };

      localip = {
        ssh_only = true;
        format = " ◯[$localipv4](bold magenta)";
        disabled = false;
      };

      memory_usage = {
        disabled = false;
      };

      time = {
        disabled = false;
        format = "[ $time]($style)";
        time_format = "%R";
        utc_time_offset = "local";
        style = "dimmed white";
      };

      git_branch = {
        format = " [$symbol$branch(:$remote_branch)]($style)";
        symbol = " ";
        style = "bright-blue";
        truncation_symbol = "⋯";
        truncation_length = 11;
        only_attached = true;
      };

      git_status = {
        style = "bold bright-blue";
        format = "([〔$ahead_behind$staged$untracked$deleted$modified$renamed$conflicted$stashed〕]($style))";
        conflicted = "[ ](bright-magenta)";
        ahead = "[│[\${count}](bold white)│](green)";
        behind = "[│[\${count}](bold white)│](red)";
        untracked = "[ ](green)";
        stashed = "[ ](white)";
        modified = "[ ](yellow)";
        staged = "[[ [$count](bold white)](bright-cyan) | ](bold bright-blue)";
        renamed = "[ ](bright-blue)";
        deleted = "[ ](red)";
      };

      golang = {
        format = "[$symbol〔[$version](white) 〕]($style)";
        symbol = "";
      };

      package = {
        format = " [pkg](italic dimmed) [$symbol$version]($style)";
        version_format = "\${raw}";
        symbol = "◨ ";
        style = "dimmed yellow italic bold";
      };

      memory_usage = {
        symbol = "▪▫▪ ";
        format = " mem [\${ram}( \${swap})]($style)";
      };

      nix_shell = {
        style = "bold blue";
        symbol = "";
        format = "[$symbol〔$state[$name](white) 〕]($style)";
        impure_msg = "[⌽ ](bold red)";
        pure_msg = "[⌾ ](bold green)";
        unknown_msg = "[◌ ](bold yellow)";
      };
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    shortcut = "a";
    mouse = true;
    clock24 = true;
    newSession = true;
    secureSocket = false;

    tmuxinator.enable = true;

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.sensible
      tmuxPlugins.tmux-fzf
    ];

    extraConfig = ''
      setw -g automatic-rename on
      set -g renumber-windows on
      set -g set-titles on

      unbind '%'
      unbind '"'
      unbind Left
      unbind Up
      unbind Down
      unbind Left
      unbind Right
      unbind C-Up
      unbind C-Down
      unbind C-Left
      unbind C-Right

      bind M-Up     split-window -v
      bind M-Down   split-window -v
      bind M-Left   split-window -h
      bind M-Right  split-window -h

      bind -r -T prefix   Up     select-pane -U
      bind -r -T prefix   Down   select-pane -D
      bind -r -T prefix   Left   select-pane -L
      bind -r -T prefix   Right  select-pane -R

      bind -r -T prefix   S-Up     resize-pane -U 5
      bind -r -T prefix   S-Down   resize-pane -D 5
      bind -r -T prefix   S-Left   resize-pane -L 5
      bind -r -T prefix   S-Right  resize-pane -R 5
    '';
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;

    themes = {
      dark_plus = builtins.readFile ./dark_plus.toml;
    };

    settings = {
      theme = "dark_plus";

      editor = {
        true-color = true;
        mouse = true;
        auto-save = true;
        cursorline = true;
        cursorcolumn = true;
        bufferline = "always";
        preview-completion-insert = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        soft-wrap.enable = true;

        whitespace = {
          render = {
            space = "all";
            tab = "all";
            newline = "none";
          };
        };

        statusline = {
          left = ["mode" "spinner" "diagnostics"];
          center = ["file-name" "separator" "version-control" "separator"];
          right = ["position" "position-percentage" "total-line-numbers"];
          separator = "|";
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };

        lsp = {
          display-inlay-hints = true;
        };

        indent-guides = {
          render = true;
          character = "╎";
          skip-levels = 1;
        };

        file-picker = {
          hidden = false;
        };
      };

      keys.normal = {
        "C-s" = ":w";
        "ret" = ["open_below" "normal_mode"];
      };
    };

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = {command = "alejandra";};
        }
        {
          name = "go";
          formatter = {command = "gofmt";};
        }
      ];
    };
  };
}
