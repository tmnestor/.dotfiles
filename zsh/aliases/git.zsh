# =============================================================================
# Git Aliases
# =============================================================================

# Basic Git Commands
alias g='git'
alias gs='git status'
alias gss='git status --short'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gau='git add --update'

# Committing
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gcf='git commit --fixup'

# Branching & Switching
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch -D'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gswc='git switch -c'

# Diffing
alias gd='git diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'
alias gdn='git diff --name-only'

# Logging & History
alias gl='git log --oneline --graph --decorate'
alias gla='git log --oneline --graph --decorate --all'
alias gll='git log --graph --pretty=format:"%C(yellow)%h%C(reset) - %C(green)(%cr)%C(reset) %s %C(blue)<%an>%C(reset)%C(red)%d%C(reset)"'
alias glp='git log --patch'
alias gls='git log --stat'

# Remote Operations
alias gf='git fetch'
alias gfa='git fetch --all'
alias gp='git push'
alias gpo='git push origin'
alias gpu='git push --set-upstream origin'
alias gpl='git pull'
alias gplo='git pull origin'
alias gpr='git pull --rebase'

# Stashing
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gsts='git stash show'
alias gstd='git stash drop'

# Merging & Rebasing
alias gm='git merge'
alias gma='git merge --abort'
alias gmff='git merge --ff-only'
alias gr='git rebase'
alias gri='git rebase --interactive'
alias grc='git rebase --continue'
alias gra='git rebase --abort'
alias grs='git rebase --skip'

# Reset & Restore
alias grst='git reset'
alias grsth='git reset --hard'
alias grsts='git reset --soft'
alias grest='git restore'
alias grests='git restore --staged'

# Show & Blame
alias gsh='git show'
alias gbl='git blame'

# Tags
alias gt='git tag'
alias gtd='git tag --delete'
alias gta='git tag --annotate'

# Worktree
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtl='git worktree list'
alias gwtr='git worktree remove'

# Utilities
alias gclean='git clean -fd'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gignore='git update-index --assume-unchanged'
alias gunignore='git update-index --no-assume-unchanged'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
