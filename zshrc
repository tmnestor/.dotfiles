# =============================================================================
# ZSH Performance Optimizations
# =============================================================================

# Enable profiling (comment out in production)
# zmodload zsh/zprof

# Fast shell startup: do a full compinit (with security checks) only when the
# cache is older than 24h, otherwise skip the checks (compinit -C) for speed.
# The dump path is passed to the anonymous function ONLY if the glob matches a
# file modified >24h ago, so $# is the trigger. (The old `[[ -z ... ]]` test
# never fired: [[ ]] does not perform globbing, so it just saw a literal string.)
zmodload zsh/complist
autoload -Uz compinit
() { (( $# )) && compinit || compinit -C } ${ZDOTDIR:-$HOME}/.zcompdump(N.mh+24)

# Suggested minor simplification for BREW_PREFIX (Optional)
# This avoids the nested if/else and uses `command -v` which is standard
if [[ -z "$BREW_PREFIX" ]]; then
    if [[ -d "/opt/homebrew" ]]; then
        export BREW_PREFIX="/opt/homebrew"
    elif command -v brew &>/dev/null; then
        export BREW_PREFIX=$(brew --prefix)
    else
        export BREW_PREFIX="/usr/local" # Fallback
    fi
fi

# =============================================================================
# Conda Environment Setup (Lazy Loading for Performance)
# =============================================================================

# Lazy load conda - only initialize when conda command is used
conda() {
    # Remove this function after first use
    unfunction conda
    
    # Initialize conda
    __conda_setup="$(${BREW_PREFIX}/Caskroom/miniforge/base/bin/conda 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "${BREW_PREFIX}/Caskroom/miniforge/base/etc/profile.d/conda.sh" ]; then
            . "${BREW_PREFIX}/Caskroom/miniforge/base/etc/profile.d/conda.sh"
        else
            export PATH="${BREW_PREFIX}/Caskroom/miniforge/base/bin:$PATH"
        fi
    fi
    unset __conda_setup
    
    # Call conda with the original arguments
    conda "$@"
}

# =============================================================================
# PATH Configuration (Improved with Zsh 'path' array)
# =============================================================================

# Define path components in an array. Order matters (first is highest priority).
typeset -U path
path=(
    # GNU tools (prioritize over BSD versions)
    "${BREW_PREFIX}/opt/gnu-sed/libexec/gnubin"
    "${BREW_PREFIX}/opt/grep/libexec/gnubin"
    "${BREW_PREFIX}/opt/coreutils/libexec/gnubin"
    "${BREW_PREFIX}/opt/make/libexec/gnubin"
    "${BREW_PREFIX}/opt/gnu-getopt/bin"

    # System paths
    "${BREW_PREFIX}/sbin"
    "${BREW_PREFIX}/opt/openssh/bin"

    # User paths
    "/Users/tod/bin"
    "$HOME/.claude/commands"   # Claude custom commands
    # "/Users/tod/.rd/bin"

    # Default system path
    $path

    # Appended paths
    "/Users/tod/.lmstudio/bin"
)
export PATH
# =============================================================================
# Environment Variables
# =============================================================================

# Data Science & ML Directories
export DATADIR=$HOME/data
export MODELDIR=$HOME/models
export CONDA_ENVS=$HOME/conda_envs
export LLM_MODELS_PATH="$HOME/PretrainedLLM"
export HF_HOME="$HOME/PretrainedLLM" # Yes I know it is repeated!

# System Configuration
export LANG=en_AU.UTF-8
export ARCHFLAGS="-arch $(uname -m)"
export FLAGS_GETOPT_CMD="${BREW_PREFIX}/bin/getopt"

# Python/Build Configuration
export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1
export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1
export FTC_OUTPUT_PATH=/Users/tod/bert_outputs

# Homebrew Optimizations
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1  # Add this for privacy

# =============================================================================
# Pure ZSH Configuration (No Oh My Zsh)
# =============================================================================

# Enable advanced completion system
# Completion configuration
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'

# Show waiting dots during completion
expand-or-complete-with-dots() {
    echo -n "\e[31m......\e[0m"
    zle expand-or-complete
    zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

# =============================================================================
# History Configuration
# =============================================================================

# EXTENDED_HISTORY (below) records an epoch timestamp per command; `fc -l -t`
# renders it on display. (HISTIMEFORMAT is a bash variable; zsh ignores it —
# the `history`/`h` aliases further down are zsh's equivalent.)
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=1000000
SAVEHIST=$HISTSIZE

# History options
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY

# Show timestamps when listing history (zsh's equivalent of bash HISTIMEFORMAT).
# `fc -l` lists; `-t FMT` formats the stored epoch time via strftime.
HIST_STAMP_FMT='%Y-%m-%d %T'
alias history="fc -l -t '${HIST_STAMP_FMT}'"   # last 16, e.g.  1042  2026-05-31 14:07:11  git status
alias h="fc -l -t '${HIST_STAMP_FMT}' 1"       # entire history with timestamps (pipe to grep/fzf)

# =============================================================================
# Shell Options
# =============================================================================

# setopt CORRECT
# setopt CORRECT_ALL
setopt AUTO_CD              # Navigate without typing cd

# Load colors
autoload -U colors && colors

# =============================================================================
# Editor Configuration
# =============================================================================

if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='code -w'
fi

# =============================================================================
# Optimized Alias System (Lazy Loading for Performance)
# =============================================================================

# Load core aliases immediately (most frequently used)
source ~/.config/zsh/aliases/core.zsh

# Load git aliases immediately (prevents lazy-loader issues)
source ~/.config/zsh/aliases/git.zsh

# Load dev-tools aliases immediately (ruff, uv, brew - prevents lazy-loader issues)
source ~/.config/zsh/aliases/dev-tools.zsh

# Load lazy-loading system (now only used for manual loading if needed)
source ~/.config/zsh/aliases/lazy-loader.zsh

# Load pretty alias printer
source ~/.config/zsh/functions/pretty-aliases.zsh

# Note: Git, UV, Ruff, and Homebrew aliases are now lazy-loaded
# They will be loaded automatically when you first use git, uv, ruff, or brew
# Or you can manually load them with: load-git, load-dev, or load-all

# =============================================================================
# Plugin Replacements (Pure ZSH)
# =============================================================================

# Directory jumping via zoxide (maintained Rust binary).
#
# This REPLACES a former hand-rolled `z()`/`chpwd()`/`_z_dirs` plugin. That
# plugin defined its own chpwd hook; when Claude Code (and similar tools) snapshot
# the shell, they capture functions but not the `typeset -A _z_dirs` declaration,
# leaving _z_dirs as a numeric array. The subscript `_z_dirs["/some/path"]` was
# then parsed as arithmetic -> "bad math expression: operand expected" on every cd.
# zoxide's hook is correct and snapshot-safe, so the home-grown version is gone.
#
# Activates only if zoxide is installed (no-op otherwise). Install: brew install zoxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"   # provides `z` (jump) and `zi` (interactive)
fi

# Simple alias finder replacement
alias-find() {
    local search="$1"
    if [[ -z "$search" ]]; then
        echo "Usage: alias-find <search_term>"
        return 1
    fi
    alias | grep -i "$search"
}

# =============================================================================
# Custom Functions
# =============================================================================

# System power management
nosleep() {
    sudo pmset -a disablesleep 1
}

yessleep() {
    sudo pmset -a disablesleep 0
}

# Git quick commit (renamed to avoid conflict with gc alias)
gcq() {
    git commit --no-verify -m "$*"
}



fh() {
    local selected
    selected=$(history | fzf --tac --no-sort --height=40% --reverse | sed 's/^[ ]*[0-9]*[ ]*[0-9-]*[ ]*[0-9:]*[ ]*//')
    if [[ -n "$selected" ]]; then
        eval "$selected"
    fi
}

# Quick directory navigation with error handling
cdl() { 
    if [[ -d "$1" ]]; then
        cd "$1" && ls -la
    else
        echo "Directory '$1' does not exist"
        return 1
    fi
}

# Extract function for various archive types
extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create and enter directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# A slightly more robust fkill
fkill() {
    local pids
    pids=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

    if [[ -n "$pids" ]]; then
        # Loop through PIDs to kill them, handles multiple selections from fzf -m
        for pid in ${(f)pids}; do
            kill -${1:-9} "$pid"
        done
    fi
}

# Quick conda environment activation
ca() {
    if [[ -n "$1" ]]; then
        conda activate "$1"
    else
        conda info --envs | fzf | awk '{print $1}' | xargs conda activate
    fi
}

# Performance measurement function
startup_time() {
    echo "Measuring ZSH startup time (10 iterations):"
    for i in {1..10}; do
        time zsh -i -c exit
    done | grep real
}

# Quick profiling function
profile_startup() {
    echo "Profiling ZSH startup..."
    zsh -i -c "zmodload zsh/zprof; source ~/.zshrc; zprof | head -20"
}

# Create a github repo from the current directory
  create_github_repo() {
      git init
      git add .
      git commit -m "🎉 Initial commit"
      gh repo create $(basename "$PWD") --public --source=. --remote=origin --push
  }

# authenticate to github from MBP
load-keys() {
    /usr/bin/ssh-add --apple-use-keychain ~/.ssh/MBP_gh
    /usr/bin/ssh-add --apple-use-keychain ~/.ssh/MBP_gl
}

# =============================================================================
# Lazy Loading for Performance
# =============================================================================

# Lazy load thefuck (slow to initialize)
fuck() {
    eval $(thefuck --alias)
    fuck
}

# =============================================================================
# Third-party Tool Integration (Lazy Loading)
# =============================================================================

# Lazy load FZF integration
_load_fzf() {
    if command -v fzf >/dev/null 2>&1; then
        source <(fzf --zsh) 2>/dev/null || {
            [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
        }
        # Bind custom history search to Ctrl-R after FZF is loaded
        bindkey '^R' fh
    fi
}

# Load FZF on first use
fzf() {
    _load_fzf
    unfunction fzf
    fzf "$@"
}

# NOTE: zsh-syntax-highlighting is sourced at the very END of this file.
# It must load last (it wraps the ZLE widgets), and it cannot be backgrounded:
# the old `{ sleep 1 && source ... } &!` ran in a throwaway subshell, so the
# highlighting never reached the interactive shell.

# iTerm2 integration (only if file exists)
[ -f "${HOME}/.iterm2_shell_integration.zsh" ] && source "${HOME}/.iterm2_shell_integration.zsh"


# =============================================================================
# My Custom Prompt Configuration (can be same in work computer)
# =============================================================================

# Only configure conda prompt if conda is available (lazy)
_setup_conda_prompt() {
    if command -v conda >/dev/null 2>&1; then
        conda config --set changeps1 false
    fi
}

# Setup conda prompt on first conda use
{
    sleep 2 && _setup_conda_prompt
} &!

# Load and configure the vcs_info module for fast git status
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats       ' [%b%u%c]'
zstyle ':vcs_info:git:*' actionformats ' [%b|%a%u%c]'
zstyle ':vcs_info:*'     unstagedstr   '!'
zstyle ':vcs_info:*'     stagedstr     '+'

# This single function will set up all dynamic parts of the prompt
precmd_prompt_setup() {
  # 1. Set up the Conda environment part
  if [[ -n $CONDA_PREFIX ]]; then
      if [[ $(basename $CONDA_PREFIX) == "base" || $(basename $CONDA_PREFIX) == "miniconda3" ]]; then
        CONDA_ENV="(base) "
      else
        CONDA_ENV="($(basename $CONDA_PREFIX)) "
      fi
  else
    CONDA_ENV=""
  fi

  # 2. Run vcs_info to update git status
  vcs_info
}


  # Convert ANSI log files to plain text
  logs2plain() {
      for f in output/logs/*.log; do
          ansifilter "$f" > "${f%.log}_plain.txt"
      done
      echo "Converted $(\ls output/logs/*.log 2>/dev/null | wc -l | tr -d ' ') log files"
  }

# Add our single setup function to the precmd hook
precmd_functions+=(precmd_prompt_setup)

# --- Define Prompt Colors and Layout ---
COLOR_CON=$'%F{141}'
COLOR_DEF=$'%f'
COLOR_USR=$'%F{247}'
COLOR_DIR=$'%F{33}'
COLOR_GIT=$'%F{215}'

setopt prompt_subst

# Define the prompt using the variables set in our precmd function
PROMPT='${COLOR_CON}${CONDA_ENV}${COLOR_USR}%n ${COLOR_DIR}%1~ ${COLOR_GIT}${vcs_info_msg_0_}${COLOR_DEF}$ '

# LuaLaTeX compilation helper — compiles in-place with TEXINPUTS set to source dir
ltx() {
    local texfile="${1:?Usage: ltx <file.tex>}"
    local texdir="${texfile:h}"
    [[ "$texdir" == "$texfile" ]] && texdir="."
    texdir="$(cd "$texdir" && pwd)"
    TEXINPUTS="${texdir}:" lualatex -interaction=nonstopmode -output-directory="$texdir" "$texfile"
}

# (Claude custom commands path lives in the `path` array above.)
export KMP_DUPLICATE_LIB_OK=TRUE
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000

# =============================================================================
# Syntax Highlighting (MUST be sourced last — it wraps the ZLE widgets)
# =============================================================================
if [ -f "${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
