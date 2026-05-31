# =============================================================================
# ~/.bash_profile — login shell entry point
# =============================================================================
# Login shells read this file (not ~/.bashrc). Source ~/.bashrc so interactive
# login shells get the same setup; keep this file to login-only concerns.
#
# Deploy: ln -s ~/.dotfiles/bash_profile ~/.bash_profile
# =============================================================================

# Load the interactive config (aliases, functions, prompt, conda, PATH)
[ -f ~/.bashrc ] && . ~/.bashrc

# Rust toolchain (cross-platform; ~/.cargo on Linux and macOS)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
