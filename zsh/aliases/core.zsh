# =============================================================================
# Core Aliases
# =============================================================================

# Python aliases
alias python='python3'
alias pip='pip3'

# Ask before deleting or overwriting, but only when a keyboard is attached to answer.
# These are functions, not aliases, so that the question is decided when the command runs:
# a tool that runs commands with no terminal gets the plain command. As aliases, such a
# tool got a prompt that nobody could answer, and hung.
unalias rm cp mv 2>/dev/null    # so that a reload replaces the aliases these once were
function rm { if [[ -t 0 ]]; then command rm -i "$@"; else command rm "$@"; fi }
function cp { if [[ -t 0 ]]; then command cp -i "$@"; else command cp "$@"; fi }
function mv { if [[ -t 0 ]]; then command mv -i "$@"; else command mv "$@"; fi }

# Navigation & Listing Aliases
alias ..='cd ..'
alias ...='cd ../..'

# Utility Aliases
alias tree='tree -C'
alias du='du -h'
alias df='df -h'
alias mkdir='mkdir -pv'
alias wget='wget -c'
# History search function
histg() {
    history | grep -i "$@"
}
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias rmpycache='find . -type d -name "__pycache__" -exec rm -r {} +'

# Listing aliases (standard ls)
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
# Modern replacements, aliased only when installed. Never write "tool || fallback": an alias is
# text substitution, so the arguments land on the fallback and the tool runs with none (bat then
# waits on the keyboard, fd lists everything). find and grep stay themselves: fd and rg take a
# different syntax, so call them by name.
(( $+commands[bat] )) && alias cat='bat --style=plain --paging=never'
alias grep='grep --color=auto'
(( $+commands[htop] )) && alias top='htop'
(( $+commands[nvim] )) && alias vim='nvim'
alias cls='clear'
alias reload='source ~/.zshrc'
alias zshconfig='code ~/.zshrc'

# Alias management
alias add-alias='~/.config/zsh/add-alias.zsh'
