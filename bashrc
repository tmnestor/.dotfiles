#!/bin/bash
# =============================================================================
# ~/.bashrc — work (Linux) bash configuration
# =============================================================================
# Companion to the macOS `zshrc` in this repo. Self-contained: it does NOT
# depend on ~/.config/zsh/* (those are zsh-only). Written defensively — paths
# and tools are guarded so it degrades gracefully where they are absent.
#
# Deploy: ln -s ~/.dotfiles/bashrc ~/.bashrc
# =============================================================================

# Only continue for interactive shells
case $- in
    *i*) ;;
      *) return ;;
esac

# =============================================================================
# Programmable completion
# =============================================================================
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# =============================================================================
# Conda Environment Setup (auto-detect install location)
# =============================================================================
for _conda_base in \
    "/opt/miniconda3" "/opt/miniforge3" "/opt/conda" \
    "$HOME/miniconda3" "$HOME/miniforge3" "$HOME/anaconda3"; do
    if [ -f "$_conda_base/etc/profile.d/conda.sh" ]; then
        . "$_conda_base/etc/profile.d/conda.sh"
        break
    fi
done
unset _conda_base

# =============================================================================
# PATH Configuration (guarded + deduplicated)
# =============================================================================
path_prepend() {
    [ -d "$1" ] || return
    case ":$PATH:" in
        *":$1:"*) ;;                 # already present — skip
        *) PATH="$1:$PATH" ;;
    esac
}
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"
path_prepend "$HOME/.claude/commands"
export PATH

# =============================================================================
# Environment Variables
# =============================================================================
# Data Science & ML directories
export DATADIR="$HOME/data"
export MODELDIR="$HOME/models"
export CONDA_ENVS="$HOME/conda_envs"
export LLM_MODELS_PATH="$HOME/PretrainedLLM"
export HF_HOME="$HOME/PretrainedLLM"

# System
export LANG="en_US.UTF-8"

# Python/build
export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1
export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1
export FTC_OUTPUT_PATH="$HOME/bert_outputs"

# Editor: vim over SSH, VS Code if available locally, else vim
if [ -n "$SSH_CONNECTION" ]; then
    export EDITOR='vim'
elif command -v code >/dev/null 2>&1; then
    export EDITOR='code -w'
else
    export EDITOR='vim'
fi

# =============================================================================
# History Configuration (bash honours HISTTIMEFORMAT directly)
# =============================================================================
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=1000000
export HISTFILESIZE=2000000
export HISTCONTROL=ignoreboth:erasedups   # ignore dups and space-prefixed cmds
export HISTTIMEFORMAT="%Y-%m-%d %T "       # timestamped history listings
shopt -s histappend                        # append across sessions, don't clobber
shopt -s cmdhist                           # keep multi-line commands as one entry
export PROMPT_COMMAND="history -a; ${PROMPT_COMMAND:-}"  # flush each cmd immediately

# =============================================================================
# Shell Options
# =============================================================================
shopt -s checkwinsize          # keep LINES/COLUMNS correct after resize
shopt -s extglob               # extended globbing
shopt -s nocaseglob            # case-insensitive globbing
shopt -s cdspell               # autocorrect minor cd typos
shopt -s dirspell              # autocorrect dir names in completion
shopt -s globstar 2>/dev/null  # bash 4+: ** recursive glob
shopt -s autocd 2>/dev/null    # bash 4+: bare dir name => cd into it

# =============================================================================
# Aliases
# =============================================================================
# Python
alias python='python3'
alias pip='pip3'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'

# Utilities
alias tree='tree -C'
alias du='du -h'
alias df='df -h'
alias mkdir='mkdir -pv'
alias wget='wget -c'
alias histg='history | grep'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias rmpycache='find . -type d -name "__pycache__" -exec rm -r {} +'

# Modern CLI tools (with fallbacks to traditional tools)
alias ls='exa --color=auto --group-directories-first 2>/dev/null || ls --color=auto'
alias ll='exa -la --icons --git 2>/dev/null || ls -alF'
alias la='exa -a 2>/dev/null || ls -A'
alias l='exa -1 2>/dev/null || ls -CF'
alias cat='bat --style=plain 2>/dev/null || cat'
alias find='fd 2>/dev/null || find'
alias grep='rg 2>/dev/null || grep --color=auto'
alias top='htop 2>/dev/null || top'
alias vim='nvim 2>/dev/null || vim'
alias cls='clear'
alias reload='source ~/.bashrc'
alias bashconfig='${EDITOR} ~/.dotfiles/bashrc'

# Conda/Mamba
alias mamba-create='mamba env create -f environment.yml'
alias mamba-update='mamba env update -f environment.yml --prune'
alias mamba-export='mamba env export > environment.yml'
alias mamba-install='mamba install -c conda-forge'

# Git
alias gs='git status'
alias gss='git status --short'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate'
alias gla='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias ga='git add'
alias gaa='git add --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'

# =============================================================================
# Custom Functions
# =============================================================================
# System power management (Linux)
nosleep() {
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
}
yessleep() {
    sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
}

# Git quick commit, bypassing hooks
gcq() {
    git commit --no-verify -m "$*"
}

# Enhanced history search with fzf
fh() {
    local selected
    selected=$(history | fzf --tac --no-sort --height=40% --reverse | sed 's/^[ ]*[0-9]*[ ]*[0-9-]*[ ]*[0-9:]*[ ]*//')
    if [ -n "$selected" ]; then
        eval "$selected"
    fi
}

# cd into a directory then list it
cdl() {
    if [ -d "$1" ]; then
        cd "$1" && ls -la
    else
        echo "Directory '$1' does not exist" >&2
        return 1
    fi
}

# Create a directory and enter it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract common archive types
extract() {
    if [ ! -f "$1" ]; then
        echo "'$1' is not a valid file" >&2
        return 1
    fi
    case "$1" in
        *.tar.bz2) tar xjf "$1"    ;;
        *.tar.gz)  tar xzf "$1"    ;;
        *.tar.xz)  tar xJf "$1"    ;;
        *.bz2)     bunzip2 "$1"    ;;
        *.rar)     unrar e "$1"    ;;
        *.gz)      gunzip "$1"     ;;
        *.tar)     tar xf "$1"     ;;
        *.tbz2)    tar xjf "$1"    ;;
        *.tgz)     tar xzf "$1"    ;;
        *.zip)     unzip "$1"      ;;
        *.Z)       uncompress "$1" ;;
        *.7z)      7z x "$1"       ;;
        *) echo "'$1' cannot be extracted via extract()" >&2 ;;
    esac
}

# Find and kill process(es) via fzf
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ -n "$pid" ]; then
        echo "$pid" | xargs kill -"${1:-9}"
    fi
}

# Quick conda environment activation (fzf picker when no arg)
ca() {
    if [ -n "$1" ]; then
        conda activate "$1"
    elif command -v fzf >/dev/null 2>&1; then
        conda env list | grep -v '^#' | fzf | awk '{print $1}' | xargs -r conda activate
    else
        conda env list
    fi
}

# =============================================================================
# Third-party Tool Integration
# =============================================================================
# fzf key bindings / completion
if command -v fzf >/dev/null 2>&1; then
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
    bind -x '"\C-r": fh'        # custom Ctrl-R history search
fi

# zoxide directory jumping (provides `z` / `zi`)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

# =============================================================================
# Prompt: (conda env) user dir [git-branch] $   — bash analogue of the zsh prompt
# =============================================================================
# Keep conda from prepending its own (env) — we render it ourselves
command -v conda >/dev/null 2>&1 && conda config --set changeps1 false 2>/dev/null

get_conda_env() {
    if [ -n "$CONDA_PREFIX" ]; then
        local env_name
        env_name=$(basename "$CONDA_PREFIX")
        if [ "$env_name" = "miniconda3" ] || [ "$env_name" = "base" ]; then
            echo "(base) "
        else
            echo "($env_name) "
        fi
    fi
}
parse_git_branch() {
    git branch 2>/dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}
COLOR_CON='\[\033[38;5;141m\]'   # conda env  (purple)
COLOR_USR='\[\033[38;5;247m\]'   # user       (grey)
COLOR_DIR='\[\033[38;5;33m\]'    # directory  (blue)
COLOR_GIT='\[\033[38;5;215m\]'   # git branch (orange)
COLOR_DEF='\[\033[0m\]'
PS1="${COLOR_CON}\$(get_conda_env)${COLOR_USR}\u ${COLOR_DIR}\W ${COLOR_GIT}\$(parse_git_branch)${COLOR_DEF}\$ "

# =============================================================================
# Linux-specific adjustments
# =============================================================================
# Color support for ls/grep via dircolors
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Friendlier `less` for non-text input
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
