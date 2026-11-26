# =============================================================================
# pretty-aliases: list the aliases, each with the comment written above it
# =============================================================================
#   pretty-aliases           every alias, grouped by the file that defines it
#   pretty-aliases <term>    only those whose name, command or comment matches
#   pa                       short for pretty-aliases

pretty-aliases() {
    # --all is accepted and ignored: every group is loaded at start-up, so
    # there is no longer a difference between loaded and available
    [[ "$1" == "--all" ]] && shift
    local search_term="$1"
    
    echo "📋 Available Aliases"
    echo "===================="
    
    # Function to parse and display aliases from a file
    _parse_alias_file() {
        local file="$1"
        local group_name="$2"
        local comment=""
        local found_aliases=false
        
        while IFS= read -r line; do
            # Skip empty lines and section headers
            [[ -z "$line" || "$line" =~ '^# =' ]] && continue
            
            if [[ "$line" =~ '^# ' ]]; then
                # Store comment for next alias
                comment="${line#\# }"
            elif [[ "$line" =~ '^alias ' ]]; then
                # Extract alias name and definition
                local alias_def="${line#alias }"
                local alias_name="${alias_def%%=*}"
                local alias_value="${alias_def#*=}"
                
                # Remove quotes from value
                alias_value="${alias_value#\'}"
                alias_value="${alias_value%\'}"
                alias_value="${alias_value#\"}"
                alias_value="${alias_value%\"}"
                
                # Apply search filter if provided
                if [[ -n "$search_term" ]]; then
                    if [[ ! "$alias_name" =~ "$search_term" && ! "$alias_value" =~ "$search_term" && ! "$comment" =~ "$search_term" ]]; then
                        comment=""
                        continue
                    fi
                fi
                
                if [[ ! "$found_aliases" == true ]]; then
                    echo -e "\n🔧 $group_name"
                    echo "$(printf '%.0s-' {1..20})"
                    found_aliases=true
                fi
                
                # Format output
                printf "%-20s → %-30s" "$alias_name" "$alias_value"
                if [[ -n "$comment" ]]; then
                    echo " # $comment"
                else
                    echo ""
                fi
                
                comment=""
            else
                # Reset comment if we hit a non-comment, non-alias line
                comment=""
            fi
        done < "$file"
    }
    
    # One heading for each alias file, named after the file
    local file
    for file in "$HOME/.config/zsh/aliases"/*.zsh(N); do
        _parse_alias_file "$file" "${file:t:r}"
    done
    
    # Show currently active aliases not in files
    echo -e "\n⚡ Runtime Aliases"
    echo "$(printf '%.0s-' {1..18})"
    
    # Get all current aliases and filter out file-based ones
    local file_aliases=()
    for file in "$HOME/.config/zsh/aliases"/*.zsh; do
        [[ ! -f "$file" ]] && continue
        while IFS= read -r line; do
            if [[ "$line" =~ '^alias ' ]]; then
                local alias_name="${line#alias }"
                alias_name="${alias_name%%=*}"
                file_aliases+=("$alias_name")
            fi
        done < "$file"
    done
    
    # Show runtime aliases
    alias | while IFS= read -r line; do
        local alias_name="${line%%=*}"
        local alias_value="${line#*=}"
        
        # Skip if this alias is from a file
        local is_file_alias=false
        for fa in "${file_aliases[@]}"; do
            [[ "$fa" == "$alias_name" ]] && is_file_alias=true && break
        done
        
        [[ "$is_file_alias" == true ]] && continue
        
        # Apply search filter
        if [[ -n "$search_term" ]]; then
            [[ ! "$alias_name" =~ "$search_term" && ! "$alias_value" =~ "$search_term" ]] && continue
        fi
        
        printf "%-20s → %s\n" "$alias_name" "$alias_value"
    done
    
    echo -e "\n💡 Usage:"
    echo "  pretty-aliases              # Show every alias"
    echo "  pretty-aliases <search>     # Search aliases"
}

# Shorter alias for convenience
alias pa='pretty-aliases'
