{ pkgs, ... }:
{
  programs.zsh = {
    enable           = true;
    enableCompletion = true;

    # ── fish-style inline grey suggestions from history ───────────
    autosuggestion.enable = true;

    # ── fish-style syntax coloring as you type ────────────────────
    syntaxHighlighting.enable = true;

    shellAliases = {
      # ── file system ───────────────────────────────────────────────
      ls   = "eza -lh --group-directories-first --icons=auto";
      lsa  = "ls -a";
      lt   = "eza --tree --level=2 --long --icons --git";
      lta  = "lt -a";

      # ── directories ───────────────────────────────────────────────
      ".."   = "cd ..";
      "..."  = "cd ../..";
      "...." = "cd ../../..";

      # ── your stack ────────────────────────────────────────────────
      nrs  = "sudo nixos-rebuild switch --flake ~/nixos-dots#aqua";
      nrb  = "sudo nixos-rebuild boot   --flake ~/nixos-dots#aqua";
      nrd  = "sudo nixos-rebuild dry-build --flake ~/nixos-dots#aqua";
      up   = "nix flake update ~/nixos && nrs";
      cat  = "bat --style=plain";
      grep = "rg";
      hme  = "nvim ~/nixos-dots/home/default.nix";
      hypc = "nvim ~/nixos-dots/home/dotfiles/hyprland/hyprland.conf";
      qsc  = "nvim ~/nixos-dots/home/dotfiles/quickshell/";
      net  = "kitty --class impala -e impala";
      lg   = "lazygit";
      v    = "nvim";
    };

    plugins = [
      {
        # Up/Down arrows search history by prefix (type nrs, Up → only nrs history)
        name = "zsh-history-substring-search";
        src  = pkgs.zsh-history-substring-search;
      }
      {
        # Replaces Tab completion menu with fzf fuzzy popup + file preview
        name = "fzf-tab";
        src  = pkgs.zshPlugins.fzf-tab;
      }
    ];

    initExtra = ''
      # ── history ───────────────────────────────────────────────────
      HISTSIZE=32768
      SAVEHIST=32768
      setopt HIST_IGNORE_DUPS    # skip consecutive duplicate commands
      setopt HIST_IGNORE_SPACE   # prefix command with space to skip saving
      setopt HIST_VERIFY         # show expanded !! before running, not immediately
      setopt SHARE_HISTORY       # sync history across all open terminals instantly

      # ── directory ─────────────────────────────────────────────────
      setopt AUTO_CD             # type a dir name alone to cd into it
      setopt AUTO_PUSHD          # every cd pushes prev dir onto stack; cd - to go back
      setopt PUSHD_IGNORE_DUPS   # no duplicate entries in the dir stack

      # ── globbing ──────────────────────────────────────────────────
      setopt EXTENDED_GLOB       # enables **, ^pattern, ~pattern, (pattern) qualifiers
      setopt GLOB_DOTS           # globs match dotfiles without explicit .*

      # ── miscellaneous ─────────────────────────────────────────────
      setopt CORRECT             # suggest correction for mistyped commands
      setopt INTERACTIVE_COMMENTS # allow # comments in interactive shell
      setopt NOTIFY              # report background job completion immediately
      setopt NO_BEEP             # no bell on errors or failed completion
      setopt LONG_LIST_JOBS      # show PID and full details when listing jobs

      # ── environment ───────────────────────────────────────────────
      export SUDO_EDITOR="$EDITOR"
      export BAT_THEME=ansi
      export MANROFFOPT="-c"
      export MANPAGER="sh -c 'col -bx | bat -l man -p'"  # colored man pages via bat

      # ── completion styling ────────────────────────────────────────
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'     # case-insensitive
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}  # colored file listing
      zstyle ':completion:*:descriptions' format '[%d]'         # show group labels
      zstyle ':completion:*' completer _expand _complete _correct _approximate
      # fzf-tab: preview directory contents with eza when tab-completing cd
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --icons $realpath'
      # fzf-tab: switch groups with < and >
      zstyle ':fzf-tab:*' switch-group '<' '>'
      # tab completion works after sudo
      zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
        /usr/sbin /usr/bin /sbin /bin

      # ── autosuggestion config ─────────────────────────────────────
      # suggest from history first, fall back to completion
      ZSH_AUTOSUGGEST_STRATEGY=(history completion)
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

      # ── vi mode ───────────────────────────────────────────────────
      bindkey -v
      KEYTIMEOUT=1  # 10ms delay for key sequences, snappier Esc

      # cursor: beam in insert mode, block in normal mode
      _set_cursor_beam()  { echo -ne '\e[6 q'; }
      _set_cursor_block() { echo -ne '\e[2 q'; }
      zle -N zle-line-init       _set_cursor_beam
      zle -N zle-keymap-select   _zle_keymap_select

      _zle_keymap_select() {
        case $KEYMAP in
          vicmd)          _set_cursor_block ;;
          viins|main)     _set_cursor_beam  ;;
        esac
      }

      # restore beam cursor when a command runs
      preexec() { _set_cursor_beam; }

      # keep useful emacs bindings in vi insert mode
      bindkey '^a' beginning-of-line
      bindkey '^e' end-of-line
      bindkey '^w' backward-kill-word
      bindkey '^u' kill-whole-line
      bindkey '^h' backward-delete-char
      bindkey '^?' backward-delete-char

      # ── history substring search binds ────────────────────────────
      # must come after bindkey -v so vi mode doesn't override them
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey -M vicmd 'k' history-substring-search-up
      bindkey -M vicmd 'j' history-substring-search-down

      # ── zoxide ────────────────────────────────────────────────────
      # smart cd: z dots → jumps to ~/nixos-dots based on frecency
      if command -v zoxide &>/dev/null; then
        eval "$(zoxide init zsh)"
        alias cd="z"
      fi

      # ── open ──────────────────────────────────────────────────────
      # open <file/url> with default app, non-blocking like macOS open
      open() (
        xdg-open "$@" >/dev/null 2>&1 &
      )

      # ── fzf ───────────────────────────────────────────────────────
      # Ctrl+R: fuzzy history search
      # Ctrl+T: fuzzy file picker, inserts path at cursor
      # Alt+C:  fuzzy cd into a directory
      if command -v fzf &>/dev/null; then
        eval "$(fzf --zsh 2>/dev/null || true)"

        if [[ "$TERM" == "xterm-kitty" ]]; then
          alias ff="fzf --preview 'case \$(file --mime-type -b {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 {} ;; *) bat --style=numbers --color=always {} ;; esac'"
        else
          alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
        fi

        # eff: pick a file with ff then open in $EDITOR
        alias eff='$EDITOR "$(ff)"'

        # sff: pick a file by recency, scp it to a destination
        sff() {
          if [ $# -eq 0 ]; then
            echo "Usage: sff <destination> (e.g. sff host:/tmp/)"
            return 1
          fi
          local file
          file=$(find . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2- | ff) \
            && [ -n "$file" ] \
            && scp "$file" "$1"
        }
      fi

      # ── suffix aliases ────────────────────────────────────────────
      # type a filename alone to open it: readme.md → nvim readme.md
      alias -s md=nvim
      alias -s nix=nvim
      alias -s c=nvim
      alias -s h=nvim
      alias -s txt=nvim

      # ── mkcd ──────────────────────────────────────────────────────
      # mkdir + cd in one: mkcd my-project
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }

      # ── extract ───────────────────────────────────────────────────
      # universal archive extractor: extract file.tar.gz, .zip, .7z, etc.
      extract() {
        case "$1" in
          *.tar.gz|*.tgz)  tar xzf "$1"  ;;
          *.tar.bz2|*.tbz) tar xjf "$1"  ;;
          *.tar.xz)        tar xJf "$1"  ;;
          *.tar)           tar xf  "$1"  ;;
          *.zip)           unzip   "$1"  ;;
          *.7z)            7z x    "$1"  ;;
          *.gz)            gunzip  "$1"  ;;
          *.xz)            unxz    "$1"  ;;
          *)               echo "unknown archive: $1" ;;
        esac
      }
    '';
  };

  programs.starship = {
    enable               = true;
    enableZshIntegration = true;
    settings = {
      add_newline     = true;
      command_timeout = 200;
      format          = "[$directory$git_branch$git_status]($style)$character";

      character = {
        success_symbol = "[❯](bold cyan)";
        error_symbol   = "[✗](bold cyan)";
      };

      directory = {
        truncation_length = 2;
        truncation_symbol = "…/";
        repo_root_style   = "bold cyan";
        repo_root_format  = "[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) ";
      };

      git_branch = {
        format = "[$branch]($style) ";
        style  = "italic cyan";
      };

      git_status = {
        format     = "[$all_status]($style)";
        style      = "cyan";
        ahead      = "⇡\${count} ";
        diverged   = "⇕⇡\${ahead_count}⇣\${behind_count} ";
        behind     = "⇣\${count} ";
        conflicted = " ";
        up_to_date = " ";
        untracked  = "? ";
        modified   = " ";
        stashed    = "";
        staged     = "";
        renamed    = "";
        deleted    = "";
      };
    };
  };
}
