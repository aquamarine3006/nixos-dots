{ pkgs, lib, ... }:
{
  # ── packages ──────────────────────────────────────────────────────────────────
  home.packages = [
    pkgs.file                 # required by ff() for kitty icat mime detection
  ];

  # ── bat ───────────────────────────────────────────────────────────────────────
  programs.bat = {
    enable       = true;
    config.theme = "ansi";
  };

  # ── session variables ─────────────────────────────────────────────────────────
  home.sessionVariables = {
    MANROFFOPT = "-c";
    MANPAGER   = "sh -c 'col -bx | bat -l man -p'";
    LESS       = "-R --mouse";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # ── fzf — HM module handles eval + keybindings ───────────────────────────────
  programs.fzf = {
    enable               = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height=60%"
      "--layout=reverse"
      "--border=rounded"
      "--info=inline"
      "--preview-window=right:50%:wrap"
    ];
  };

  # ── zoxide ────────────────────────────────────────────────────────────────────
  # enableZshIntegration disabled: HM injects at priority 851 which is too early,
  # triggering _ZO_DOCTOR on every shell open (HM issue #9349).
  # Initialised manually at the end of initContent (priority 1000) instead.
  # When #9349 is fixed: flip to true and remove the eval line in initContent.
  programs.zoxide = {
    enable               = true;
    enableZshIntegration = false;
  };

  # ── atuin — local SQLite history, replaces Ctrl+R and up-arrow ───────────────
  # enableZshIntegration binds ctrl-r AND up-arrow automatically.
  # auto_sync = false → everything stays local, no account needed.
  # atuin also prepends itself to zsh-autosuggestion's strategy list on init.
  programs.atuin = {
    enable               = true;
    enableZshIntegration = true;
    settings = {
      auto_sync     = false;
      search_mode   = "fuzzy";
      style         = "compact";
      inline_height = 20;
      show_help     = false;
      filter_mode_shell_up_key_binding = "session";
    };
  };

  # ── nix-your-shell — stay in zsh inside `nix shell` / `nix develop` ──────────
  programs.nix-your-shell = {
    enable               = true;
    enableZshIntegration = true;
  };

  # ── zsh ───────────────────────────────────────────────────────────────────────
  programs.zsh = {
    enable           = true;
    # disabled: HM runs compinit without -C, costing ~0.7s every open.
    # managed manually in initContent with -C to always use cache.
    enableCompletion = false;

    defaultKeymap = "emacs";

    autosuggestion = {
      enable   = true;
      strategy = [ "history" "completion" ];
    };

    syntaxHighlighting.enable = false;

    localVariables = {
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = "20";
      ZSH_AUTOSUGGEST_USE_ASYNC       = "1";
    };

    sessionVariables = {
      SUDO_EDITOR = "$EDITOR";
    };

    shellAliases = {
      cd  = "z";
      eff = ''$EDITOR "$(ff)"'';
    };

    history = {
      size                  = 50000;
      save                  = 50000;
      ignoreDups            = true;
      ignoreAllDups         = true;
      ignoreSpace           = true;
      extended              = true;
      share                 = true;
      expireDuplicatesFirst = true;
    };

    # ── abbreviations ─────────────────────────────────────────────────────────
    # Requires HM on nixos-unstable or ≥25.05.
    # Known broken on 24.11 (wrong plugin install path) — see HM issue #6109.
    # $HOME not expanded at definition time — hardcode path instead.
    zsh-abbr = {
      enable = true;
      abbreviations = {
        # filesystem
        ls   = "eza -lh --group-directories-first --icons=auto";
        lsa  = "eza -lah --group-directories-first --icons=auto";
        lt   = "eza --tree --level=2 --long --icons --git";
        lta  = "eza --tree --level=2 --long --icons --git -a";
        cat  = "bat --style=plain";
        grep = "rg";
        # apps
        lg   = "lazygit";
        v    = "nvim";
        net  = "kitty --class impala -e impala";
        # nixos-dots
        hme  = "nvim ~/nixos-dots/home/default.nix";
        hypc = "nvim ~/nixos-dots/home/dotfiles/hyprland/hyprland.conf";
        qsc  = "nvim ~/nixos-dots/home/dotfiles/quickshell/";
        # git
        g    = "git";
        ga   = "git add";
        gc   = "git commit";
        gp   = "git push";
        gst  = "git status";
        gd   = "git diff";
        gl   = "git log --oneline --graph";
        # nix
        ns   = "nix shell";
        nr   = "nix run";
        # nixos rebuild — quoted to prevent # glob expansion
        nrs  = "sudo nixos-rebuild switch --flake '/home/aqua/nixos-dots#aqua'";
        nrb  = "sudo nixos-rebuild boot --flake '/home/aqua/nixos-dots#aqua'";
        nrd  = "sudo nixos-rebuild dry-build --flake '/home/aqua/nixos-dots#aqua'";
        nrt  = "sudo nixos-rebuild test --flake '/home/aqua/nixos-dots#aqua'";
        up   = "nix flake update /home/aqua/nixos-dots && sudo nixos-rebuild switch --flake '/home/aqua/nixos-dots#aqua'";
      };
    };

    # ── plugins ───────────────────────────────────────────────────────────────
    # Load order is critical:
    #   1. fzf-tab                      — must precede fast-syntax-highlighting
    #   2. you-should-use               — order-independent
    #   3. zsh-bd                       — order-independent
    #   4. zsh-autopair                 — order-independent
    #   5. zsh-history-substring-search — before fast-syntax-highlighting
    #   6. nix-zsh-completions          — order-independent
    #   7. fast-syntax-highlighting     — MUST be last; wraps all ZLE widgets
    plugins = [
      {
        name = "fzf-tab";
        src  = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      {
        name = "you-should-use";
        src  = pkgs.zsh-you-should-use;
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
      }
      {
        name = "zsh-bd";
        src  = pkgs.zsh-bd;
        file = "share/plugins/zsh-bd/bd.plugin.zsh";
      }
      {
        name = "zsh-autopair";
        src  = pkgs.zsh-autopair;
        file = "share/zsh/zsh-autopair/autopair.zsh";
      }
      {
        name = "zsh-history-substring-search";
        src  = pkgs.zsh-history-substring-search;
        file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
      {
        name = "nix-zsh-completions";
        src  = pkgs.nix-zsh-completions;
        file = "share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh";
      }
      {
        name = "fast-syntax-highlighting";
        src  = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh";
      }
    ];

    initContent = ''
      # ── compinit — always use cache, skip security check ─────────────────────
      # enableCompletion=false above prevents HM running compinit without -C.
      # -C: skip security check, always use .zcompdump cache.
      # Run `rm ~/.zcompdump*` to force rebuild when adding new completions.
      autoload -Uz compinit
      compinit -C -d "''${ZDOTDIR:-$HOME}/.zcompdump"

      # ── options ──────────────────────────────────────────────────────────────
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT
      setopt EXTENDED_GLOB
      setopt GLOB_DOTS
      setopt CORRECT
      setopt INTERACTIVE_COMMENTS
      setopt NOTIFY
      setopt NO_BEEP
      setopt LONG_LIST_JOBS
      setopt HIST_VERIFY
      setopt HIST_REDUCE_BLANKS

      # ── history-substring-search bindings ─────────────────────────────────────
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

      # ── completion styling ────────────────────────────────────────────────────
      zstyle ':completion:*'              menu select
      zstyle ':completion:*'              matcher-list 'm:{a-z}={A-Z}' 'r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*'              list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*:warnings'     format 'No matches for: %d'
      zstyle ':completion:*'              completer _expand _complete _extensions _correct _approximate
      zstyle ':completion:*'              group-name ""
      zstyle ':completion:*'              extra-verbose true
      zstyle ':completion:*:*:kill:*'     menu yes select
      zstyle ':completion:*:sudo:*'       command-path \
        /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

      # ── fzf-tab previews ─────────────────────────────────────────────────────
      zstyle ':fzf-tab:*'                     fzf-flags \
        '--height=60%' \
        '--preview-window=right:50%:wrap' \
        '--border=rounded' \
        '--info=inline'
      zstyle ':fzf-tab:*'                     switch-group '(' ')'
      zstyle ':fzf-tab:complete:cd:*'         fzf-preview 'eza -1 --icons --color=always $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --icons --color=always $realpath'
      zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-header -w -w'
      zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'
      zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
      zstyle ':fzf-tab:complete:(-equal-|-brace-parameter-|export|unset|expand):*' \
        fzf-preview 'echo ''${(P)word}'
      zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
        'command -v delta &>/dev/null && git diff $word | delta || git diff --color=always $word'
      zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
        'git log --color=always --oneline --graph $word'
      zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
        'case "$group" in
           "modified file") command -v delta &>/dev/null \
             && git diff $word | delta \
             || git diff --color=always $word ;;
           "recent commit object name") command -v delta &>/dev/null \
             && git show --color=always $word | delta \
             || git show --color=always $word ;;
           *) git log --color=always --oneline --graph $word ;;
         esac'

      # ── fzf file picker ───────────────────────────────────────────────────────
      ff() {
        if [[ "$TERM" == "xterm-kitty" ]] && command -v file &>/dev/null; then
          fzf --preview 'case $(file --mime-type -b {}) in
            image/*) kitty icat --clear --transfer-mode=memory --stdin=no \
                       --place=''${FZF_PREVIEW_COLUMNS}x''${FZF_PREVIEW_LINES}@0x0 {} ;;
            *)       bat --style=numbers --color=always {} ;;
          esac'
        else
          fzf --preview 'bat --style=numbers --color=always {}'
        fi
      }

      # sff: pick a file with ff then scp it to a remote destination
      sff() {
        [ $# -eq 0 ] && { printf 'Usage: sff <user@host:/path/>\n' >&2; return 1; }
        local sel
        sel=$(find . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2- | ff) \
          && [[ -n "$sel" ]] && scp "$sel" "$1"
      }

      # ── suffix aliases ────────────────────────────────────────────────────────
      alias -s {md,nix,c,h,txt,lua,py,rs,go,js,ts,json,yaml,toml}=nvim

      # ── utility functions ─────────────────────────────────────────────────────
      mkcd()   { mkdir -p "$1" && cd "$1"; }
      tree()   { eza --tree --level=''${1:-2} --icons --git --color=always; }

      extract() {
        case "$1" in
          *.tar.gz|*.tgz)  tar xzf "$1"        ;;
          *.tar.bz2|*.tbz) tar xjf "$1"        ;;
          *.tar.xz)        tar xJf "$1"         ;;
          *.tar.zst)       tar --zstd -xf "$1" ;;
          *.tar)           tar xf  "$1"         ;;
          *.zip)           unzip   "$1"         ;;
          *.7z)            7z x    "$1"         ;;
          *.gz)            gunzip  "$1"         ;;
          *.xz)            unxz    "$1"         ;;
          *.bz2)           bunzip2 "$1"         ;;
          *) printf 'unknown archive: %s\n' "$1" >&2; return 1 ;;
        esac
      }

      # ── zoxide (must be last — see programs.zoxide comment above) ─────────────
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
    '';
  };

  # ── starship ─────────────────────────────────────────────────────────────────
  # Colors use ANSI palette indices — resolves to whatever kitty loads from
  # colors.conf, so theme changes propagate automatically with no hardcoding.
  # color4=accent teal  color6=muted teal  color2=lavender
  # color1=error red    color8=dimmed      color7=foreground
  programs.starship = {
    enable               = true;
    enableZshIntegration = true;
    settings = {
      add_newline     = true;
      command_timeout = 500;

      format = "$directory$git_branch$git_status$nix_shell$cmd_duration$fill$time$character";

      fill = { symbol = " "; };

      character = {
        success_symbol = "[❯](bold color4)";
        error_symbol   = "[❯](bold color1)";
      };

      time = {
        disabled    = false;
        format      = "[$time ]($style)";
        style       = "color8";
        time_format = "%H:%M";
      };

      directory = {
        truncation_length = 2;
        truncation_symbol = "…/";
        repo_root_style   = "bold color4";
        repo_root_format  = "[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) ";
        style             = "color6";
      };

      git_branch = {
        format = "[$branch]($style) ";
        style  = "italic color2";
      };

      git_status = {
        format     = "[$all_status]($style)";
        style      = "color6";
        ahead      = "⇡\${count} ";
        diverged   = "⇕⇡\${ahead_count}⇣\${behind_count} ";
        behind     = "⇣\${count} ";
        conflicted = " ";
        up_to_date = "";
        untracked  = "";
        modified   = " ";
        stashed    = "≡ ";
        staged     = " ";
        renamed    = "» ";
        deleted    = " ";
      };

      nix_shell = {
        disabled    = false;
        format      = "[$symbol$state ]($style)";
        symbol      = " ";
        style       = "color8";
        impure_msg  = "nix";
        pure_msg    = "nix·pure";
        unknown_msg = "nix·dev";
      };

      cmd_duration = {
        disabled           = false;
        min_time           = 2000;
        format             = "[took $duration ]($style)";
        style              = "color8";
        show_notifications = false;
      };
    };
  };
}
