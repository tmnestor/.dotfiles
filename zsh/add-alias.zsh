#!/bin/zsh

# Quick alias addition script

usage() {
    echo "Usage: add-alias <group> <alias_name> <command> [description]"
    echo ""
    echo "Groups available:"
    echo "  core      - Essential aliases (always loaded)"
    echo "  git       - Git-related aliases"
    echo "  dev-tools - Development tools (uv, ruff, brew, conda/mamba)"
    echo ""
    echo "Example:"
    echo "  add-alias git gp 'git push' 'Push to remote'"
    echo "  add-alias core ll 'ls -la' 'Long listing'"
}

if [[ $# -lt 3 ]]; then
    usage
    exit 1
fi

group="$1"
alias_name="$2"
command="$3"
description="${4:-}"

alias_file="$HOME/.config/zsh/aliases/${group}.zsh"

if [[ ! -f "$alias_file" ]]; then
    echo "Error: Group '$group' not found. Available groups:"
    ls ~/.config/zsh/aliases/*.zsh | xargs -I {} basename {} .zsh
    exit 1
fi

# Format the alias line
if [[ -n "$description" ]]; then
    alias_line="alias ${alias_name}='${command}'  # ${description}"
else
    alias_line="alias ${alias_name}='${command}'"
fi

# Add to file
echo "$alias_line" >> "$alias_file"

echo "✅ Added alias '$alias_name' to $group group"
echo "   Command: $command"
[[ -n "$description" ]] && echo "   Description: $description"
echo ""
echo "💡 Reload with: source ~/.zshrc"
echo "   Or load group: load-${group}"
