# =============================================================================
# ~/.zshrc: interactive zsh configuration (macOS, Homebrew)
# =============================================================================
#
# This file lives in ~/.dotfiles (~/.zshrc is a symlink to it). The alias and
# function files it sources live in ~/.dotfiles/zsh, linked as ~/.config/zsh.
#
# Sections, in the order they must run:
#    1. Completion            7. Shell options
#    2. Homebrew prefix       8. Aliases and helper files
#    3. PATH                  9. Tools (zoxide, fzf, thefuck)
#    4. Environment          10. Functions
#    5. Conda (lazy)         11. Prompt
#    6. History              12. Syntax highlighting (must be last)
#
# Order matters in three places:
#   - aliases load before the functions, because zsh expands an alias inside a
#     function body when the function is defined;
#   - iTerm2's integration loads before the prompt, so its precmd hook runs
#     ahead of ours;
#   - syntax highlighting loads last, because it wraps every ZLE widget.
#
# To profile start-up, uncomment the next line and run `zprof` in a new shell.
# zmodload zsh/zprof

# =============================================================================
# 1. Completion
# =============================================================================

# Run the full compinit (with its security checks) only when the dump is more
# than 24 hours old; otherwise skip the checks (compinit -C) for speed. The glob
# qualifier (N.mh+24) passes the dump to the anonymous function only when it is
# that old, so $# is the trigger. ([[ -z ... ]] cannot do this: [[ ]] does not
# glob, so it only ever sees a literal string.)
zmodload zsh/complist
autoload -Uz compinit
() { (( $# )) && compinit || compinit -C } ${ZDOTDIR:-$HOME}/.zcompdump(N.mh+24)

# Menu selection, case-insensitive and partial-word matching, coloured groups
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'

# Show red dots on Tab while a slow completion runs
expand-or-complete-with-dots() {
    echo -n "\e[31m......\e[0m"
    zle expand-or-complete
    zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

# =============================================================================
# 2. Homebrew prefix
# =============================================================================

# /opt/homebrew on Apple silicon; ask brew elsewhere; /usr/local as a last resort
if [[ -z "$BREW_PREFIX" ]]; then
    if [[ -d "/opt/homebrew" ]]; then
        export BREW_PREFIX="/opt/homebrew"
    elif command -v brew &>/dev/null; then
        export BREW_PREFIX=$(brew --prefix)
    else
        export BREW_PREFIX="/usr/local"
    fi
fi

# =============================================================================
# 3. PATH
# =============================================================================

# Highest priority first; typeset -U drops duplicates. The GNU directories come
# first on purpose: sed, grep, coreutils, make and findutils are the GNU
# versions here, so scripts must use GNU syntax (sed -i, not sed -i '').
typeset -U path
path=(
    # GNU tools ahead of the macOS (BSD) versions
    "${BREW_PREFIX}/opt/gnu-sed/libexec/gnubin"
    "${BREW_PREFIX}/opt/grep/libexec/gnubin"
    "${BREW_PREFIX}/opt/coreutils/libexec/gnubin"
    "${BREW_PREFIX}/opt/make/libexec/gnubin"
    "${BREW_PREFIX}/opt/findutils/libexec/gnubin"
    "${BREW_PREFIX}/opt/gnu-getopt/bin"

    # Homebrew system tools and a newer OpenSSH
    "${BREW_PREFIX}/sbin"
    "${BREW_PREFIX}/opt/openssh/bin"

    # Personal scripts
    "/Users/tod/bin"
    "$HOME/.claude/commands"
    # "/Users/tod/.rd/bin"

    # The inherited system path
    $path

    # Appended, so they never shadow anything above
    "/Users/tod/.lmstudio/bin"
    # Wolfram CLI (wolfram, WolframKernel); WolframScript.app also links wolframscript into /usr/local/bin
    "/Applications/Wolfram.app/Contents/MacOS"
)
export PATH

# =============================================================================
# 4. Environment
# =============================================================================

# Data and model stores
export DATADIR=$HOME/data
export MODELDIR=$HOME/models
export CONDA_ENVS=$HOME/conda_envs
export LLM_MODELS_PATH="$HOME/PretrainedLLM"
export HF_HOME="$HOME/PretrainedLLM"    # the Hugging Face cache shares the same store

# Document parsers: resolve models from the local store, not the HF cache.
# MinerU reads models-dir.{vlm,pipeline} from this JSON; keeping it in the
# store avoids creating a ~/mineru.json. Docling requires its artifacts dir
# to contain <org>--<name> subdirs, so it gets its own subtree.
export MINERU_TOOLS_CONFIG_JSON="$LLM_MODELS_PATH/mineru.json"
export DOCLING_ARTIFACTS_PATH="$LLM_MODELS_PATH/docling-artifacts"

# Locale and build flags
export LANG=en_AU.UTF-8
export ARCHFLAGS="-arch $(uname -m)"
export FLAGS_GETOPT_CMD="${BREW_PREFIX}/bin/getopt"
export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1
export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1
export FTC_OUTPUT_PATH=/Users/tod/bert_outputs

# Homebrew: no hints, no automatic update before each install, no analytics
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1

# Editor: vim over SSH, VS Code (waiting for the file to close) locally
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='code -w'
fi

export CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000

# =============================================================================
# 5. Conda (lazy)
# =============================================================================

# Initialising conda costs a noticeable fraction of a second, so it waits until
# conda is first used: this stand-in removes itself, runs the real set-up, then
# repeats the original command. conda's own prompt prefix is off (changeps1:
# false in ~/.condarc); the prompt in section 11 shows the environment instead.
conda() {
    unfunction conda

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

    conda "$@"
}

# =============================================================================
# 6. History
# =============================================================================

# A million entries, shared between open shells as they are typed. Each entry
# carries an epoch timestamp (EXTENDED_HISTORY), shown by `fc -l -t`.
# (HISTIMEFORMAT is a bash variable and zsh ignores it; the `history` and `h`
# aliases below are zsh's equivalent.)
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=1000000
SAVEHIST=$HISTSIZE

setopt EXTENDED_HISTORY         # store a timestamp with each entry
setopt SHARE_HISTORY            # share history between open shells
setopt APPEND_HISTORY           # append to the file instead of replacing it
setopt INC_APPEND_HISTORY       # write each entry as soon as it is entered
setopt HIST_EXPIRE_DUPS_FIRST   # trim duplicates first when the history is full
setopt HIST_IGNORE_DUPS         # skip a command identical to the one before
setopt HIST_FIND_NO_DUPS        # show each match once when searching
setopt HIST_REDUCE_BLANKS       # collapse runs of blanks
setopt HIST_IGNORE_SPACE        # a leading space keeps a command out of history
setopt HIST_VERIFY              # show an expanded !-reference before running it

# Timestamped listings: `history` shows the last 16 entries, `h` all of them,
# e.g.  1042  2026-05-31 14:07:11  git status
HIST_STAMP_FMT='%Y-%m-%d %T'
alias history="fc -l -t '${HIST_STAMP_FMT}'"
alias h="fc -l -t '${HIST_STAMP_FMT}' 1"

# =============================================================================
# 7. Shell options
# =============================================================================

setopt AUTO_CD                  # type a directory name to cd into it
# setopt CORRECT
# setopt CORRECT_ALL

# Named colours ($fg[red] and so on) for scripts and prompts
autoload -U colors && colors

# =============================================================================
# 8. Aliases and helper files
# =============================================================================

# All alias groups load now. (They were once lazy-loaded on first use of git,
# uv, ruff or brew; the wrapper functions that did it broke shell start-up.)
# These must come before section 10: see the note at the top.
source ~/.config/zsh/aliases/core.zsh           # safety, listing, Python, utilities
source ~/.config/zsh/aliases/git.zsh            # git shortcuts
source ~/.config/zsh/aliases/dev-tools.zsh      # uv, ruff, Homebrew, conda/mamba
source ~/.config/zsh/aliases/lazy-loader.zsh    # load_aliases, alias-status

source ~/.config/zsh/functions/pretty-aliases.zsh   # pretty-aliases (pa, paa)
source ~/.config/zsh/functions/bedrock.zsh          # bedrock-ip

# =============================================================================
# 9. Tools (zoxide, fzf, thefuck)
# =============================================================================

# zoxide: `z` jumps to a frequent directory, `zi` picks one interactively.
# It replaced a hand-rolled z() plugin whose chpwd hook broke inside tools that
# snapshot the shell: a snapshot keeps functions but not the plugin's
# `typeset -A _z_dirs`, so _z_dirs["/some/path"] was read as arithmetic and
# every cd failed with "bad math expression". zoxide's hook is snapshot-safe.
# A no-op until zoxide is installed (brew install zoxide).
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# fzf: its key bindings (Ctrl-R history search, Ctrl-T files, Alt-C cd) load on
# the first call of fzf, by the same self-removing stand-in as conda.
_load_fzf() {
    if command -v fzf >/dev/null 2>&1; then
        # fzf's own Ctrl-R widget searches the history; fh (section 10) is a
        # plain function, not a ZLE widget, so it cannot be bound to a key
        source <(fzf --zsh) 2>/dev/null || {
            [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
        }
    fi
}

fzf() {
    _load_fzf
    unfunction fzf
    fzf "$@"
}

# thefuck: corrects the previous command; slow to initialise, so also lazy
fuck() {
    eval $(thefuck --alias)
    fuck
}

# =============================================================================
# 10. Functions
# =============================================================================

# --- Directories and files ---------------------------------------------------

# cd into a directory and list it
cdl() {
    if [[ -d "$1" ]]; then
        cd "$1" && ls -la
    else
        echo "Directory '$1' does not exist"
        return 1
    fi
}

# Create a directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Unpack an archive of any common type
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
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Strip ANSI colour codes from output/logs/*.log into *_plain.txt files
logs2plain() {
    for f in output/logs/*.log; do
        ansifilter "$f" > "${f%.log}_plain.txt"
    done
    echo "Converted $(\ls output/logs/*.log 2>/dev/null | wc -l | tr -d ' ') log files"
}

# Compile a .tex file with LuaLaTeX in its own directory, with that directory
# on TEXINPUTS so local style and input files are found
ltx() {
    local texfile="${1:?Usage: ltx <file.tex>}"
    local texdir="${texfile:h}"
    [[ "$texdir" == "$texfile" ]] && texdir="."
    texdir="$(cd "$texdir" && pwd)"
    TEXINPUTS="${texdir}:" lualatex -interaction=nonstopmode -output-directory="$texdir" "$texfile"
}

# --- History and aliases -----------------------------------------------------

# Search the whole history with fzf and run the choice
# (`history` alone lists only the last 16 entries)
fh() {
    local selected
    selected=$(fc -l -t "$HIST_STAMP_FMT" 1 | fzf --tac --no-sort --height=40% --reverse \
        | sed 's/^[ ]*[0-9]*[ ]*[0-9-]*[ ]*[0-9:]*[ ]*//')
    if [[ -n "$selected" ]]; then
        eval "$selected"
    fi
}

# List the aliases whose name or definition matches a term
alias-find() {
    local search="$1"
    if [[ -z "$search" ]]; then
        echo "Usage: alias-find <search_term>"
        return 1
    fi
    alias | grep -i "$search"
}

# --- Processes and power -----------------------------------------------------

# Pick processes with fzf (Tab selects several) and kill them; signal 9
# unless another is given, e.g. fkill 15
fkill() {
    local pids
    pids=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [[ -n "$pids" ]]; then
        for pid in ${(f)pids}; do
            kill -${1:-9} "$pid"
        done
    fi
}

# Stop the Mac sleeping (for long runs), and allow it again
nosleep() {
    sudo pmset -a disablesleep 1
}

yessleep() {
    sudo pmset -a disablesleep 0
}

# --- Conda -------------------------------------------------------------------

# Activate an environment: `ca ENV`, or pick one with fzf. Activation has to
# run in this shell, so the choice is captured first (piping it into
# `xargs conda activate` ran conda in a child process, where it changes nothing).
ca() {
    local env="$1"
    if [[ -z "$env" ]]; then
        env=$(conda env list | command grep -v '^#' | fzf | awk '{print $1}')
        [[ -z "$env" ]] && return 1
    fi
    conda activate "$env"
}

# --- Git and GitHub ----------------------------------------------------------
# (GitHub SSH needs no ssh-add here: ~/.ssh/config sets IdentityFile,
# AddKeysToAgent and UseKeychain.)

# Commit with a message, e.g. gcq fix the typo; pre-commit hooks still run.
# (Named gcq because gc is already the alias for git commit.)
gcq() {
    git commit -m "$*"
}

# Create a GitHub repo from the current directory. It lists what would be
# committed and asks before committing; the repo is private unless called as
# `create_github_repo --public`.
create_github_repo() {
    local visibility="--private"
    [[ "$1" == "--public" ]] && visibility="--public"
    git init
    git add .
    git status --short
    if ! read -q "?Commit these files and create a ${visibility#--} repo? [y/N] "; then
        echo
        echo "Stopped: the files are staged but not committed (git reset to unstage)."
        return 1
    fi
    echo
    git commit -m "🎉 Initial commit" &&
        gh repo create "$(basename "$PWD")" "$visibility" --source=. --remote=origin --push
}

# --- Shell start-up timing ---------------------------------------------------

# Time ten start-ups. zsh's `time` reports on stderr, in a line ending "total".
startup_time() {
    echo "Measuring ZSH startup time (10 iterations):"
    for i in {1..10}; do
        time zsh -i -c exit
    done 2>&1 | command grep total
}

# The 20 most expensive steps of start-up, by zprof
profile_startup() {
    echo "Profiling ZSH startup..."
    zsh -i -c "zmodload zsh/zprof; source ~/.zshrc; zprof | head -20"
}

# =============================================================================
# 11. Prompt
# =============================================================================

# iTerm2 shell integration (marks, current directory, host). It comes before
# the prompt hook below so that its own precmd hook runs first.
[ -f "${HOME}/.iterm2_shell_integration.zsh" ] && source "${HOME}/.iterm2_shell_integration.zsh"

# Layout:  (env) user dir [branch!+] $
# The same prompt works on the work computer.

# Git branch and state via vcs_info: ! marks unstaged changes, + staged ones
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats       ' [%b%u%c]'
zstyle ':vcs_info:git:*' actionformats ' [%b|%a%u%c]'
zstyle ':vcs_info:*'     unstagedstr   '!'
zstyle ':vcs_info:*'     stagedstr     '+'

# Before each prompt: name the active conda environment and refresh vcs_info
precmd_prompt_setup() {
    if [[ -n $CONDA_PREFIX ]]; then
        if [[ $(basename $CONDA_PREFIX) == "base" || $(basename $CONDA_PREFIX) == "miniconda3" ]]; then
            CONDA_ENV="(base) "
        else
            CONDA_ENV="($(basename $CONDA_PREFIX)) "
        fi
    else
        CONDA_ENV=""
    fi
    vcs_info
}
precmd_functions+=(precmd_prompt_setup)

# Colours: 256-colour palette numbers
COLOR_CON=$'%F{141}'    # conda environment: lavender
COLOR_DEF=$'%f'         # back to the default
COLOR_USR=$'%F{247}'    # user name: grey
COLOR_DIR=$'%F{33}'     # directory: blue
COLOR_GIT=$'%F{215}'    # git branch: orange

# prompt_subst re-reads the variables above at every prompt
setopt prompt_subst
PROMPT='${COLOR_CON}${CONDA_ENV}${COLOR_USR}%n ${COLOR_DIR}%1~ ${COLOR_GIT}${vcs_info_msg_0_}${COLOR_DEF}$ '

# =============================================================================
# 12. Syntax highlighting (must be last)
# =============================================================================

# It wraps every ZLE widget, so it must load after all of them are defined.
# It cannot be backgrounded either: an old `{ sleep 1 && source ... } &!`
# ran in a throwaway subshell, so the highlighting never reached this shell.
if [ -f "${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
