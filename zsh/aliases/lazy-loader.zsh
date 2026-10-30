# =============================================================================
# Lazy Loading Alias Manager
# =============================================================================

# Track which alias groups have been loaded
typeset -A _LOADED_ALIAS_GROUPS

# Function to load alias groups on demand
load_aliases() {
    local group="$1"
    local alias_file="$HOME/.config/zsh/aliases/${group}.zsh"
    
    if [[ -f "$alias_file" && -z "${_LOADED_ALIAS_GROUPS[$group]}" ]]; then
        source "$alias_file"
        _LOADED_ALIAS_GROUPS[$group]=1
        # echo "Loaded $group aliases"  # Removed this line
    fi
}

# All aliases are now loaded immediately in .zshrc (not lazy-loaded)
# This prevents shell initialization issues with wrapper functions
#
# Previously lazy-loaded:
#   - git aliases (100 lines)
#   - dev-tools aliases (76 lines) - ruff, uv, brew
#
# These are loaded immediately for reliability with negligible performance impact

# Manual alias loading functions (now just informational)
alias load-git='echo "Git aliases are already loaded"'
alias load-dev='echo "Dev-tools aliases are already loaded"'
alias load-all='echo "All aliases are already loaded"'

# Function to show loaded alias groups
alias-status() {
    echo "Loaded alias groups:"
    for group in ${(k)_LOADED_ALIAS_GROUPS}; do
        echo "  ✓ $group"
    done
    
    echo "\nAvailable alias groups:"
    for file in ~/.config/zsh/aliases/*.zsh; do
        local basename=${file:t:r}
        if [[ -z "${_LOADED_ALIAS_GROUPS[$basename]}" ]]; then
            echo "  ○ $basename (use: load-$basename or load_aliases $basename)"
        fi
    done
}
