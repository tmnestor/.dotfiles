# dotfiles

The shell, git and Homebrew set-up of a Mac that uses zsh, with a bash configuration for Linux machines.

I learned about dotfiles at [Udemy](https://www.udemy.com/course/dotfiles-from-start-to-finish-ish/?referralCode=445BE0B541C48FE85276).

## What is here

| File | Linked as | What it is |
|---|---|---|
| `zshrc` | `~/.zshrc` | Interactive zsh, in twelve numbered sections whose order matters (see its header) |
| `zsh/` | `~/.config/zsh` | The alias files (`aliases/`) and functions (`functions/`) that `zshrc` sources |
| `bashrc` | `~/.bashrc` | Interactive bash, for Linux machines and for bash on the Mac |
| `bash_profile` | `~/.bash_profile` | Login bash: it sources `bashrc` |
| `gitconfig` | `~/.gitconfig` | Git identity, colours, aliases and credential helpers |
| `Brewfile` | not linked | Every Homebrew formula and cask, VS Code extension and global npm package installed |
| `macos` | `~/.macos`, optional | macOS defaults, taken from <https://mths.be/macos> in 2022. Not run or checked since: read it before running any of it |

The files are linked, not copied, so an edit in this folder is live in the next shell that starts, whether
or not it has been committed.

## Rules the shell files keep

These files are read by a person at a keyboard, and also by tools that take a snapshot of the shell (its
aliases, functions and options) and then run commands with no terminal attached. Each rule below is here
because breaking it once cost a hung command or a silently wrong result.

1. **Never alias a command to `tool || fallback`.** An alias is text substitution, so the arguments land on
   the fallback and the tool runs with none: `cat FILE` became `bat` reading the keyboard. Alias a
   modern tool only when it is installed, and to itself alone.
2. **Nothing prompts unless a keyboard is attached.** `rm`, `cp` and `mv` ask before deleting or
   overwriting only when standard input is a terminal. They are functions for that reason: an alias to
   `rm -i` is copied into a snapshot and then asks a question nobody can answer.
3. **`find` and `grep` stay themselves.** `fd` and `rg` take a different syntax; call them by name.
4. **No hook may depend on state a snapshot does not keep.** A snapshot keeps functions but not a variable
   declared with `typeset -A`, so a `chpwd` hook that read one broke every `cd`. This is why directory
   jumping is `zoxide` and not a hand-written plugin.
5. **The GNU tools come first on the `PATH`** (`sed`, `grep`, coreutils, `make`, findutils). Write GNU
   syntax: `sed -i 's/a/b/' f`, not `sed -i '' ...`.
6. **A stand-in that loads a tool on first use removes itself first** (`conda`, `fzf`, `fuck`), so that a
   missing tool ends in "command not found" and not in a function calling itself.

After any edit, both of these must hold before the change is committed:

```zsh
zsh -i -c exit     # prints nothing (iTerm adds its own marks, which do not count)
bash -n ~/.dotfiles/bashrc
```

## Keeping Homebrew and the Brewfile current

`zshrc` sets `HOMEBREW_NO_AUTO_UPDATE`, so Homebrew never refreshes itself: nothing is updated until it is
done by hand. Do it every few weeks.

```zsh
brew update                 # refresh what Homebrew knows; changes no package
brew outdated               # read the list before going on
brew upgrade                # upgrade the formulae, and the casks that do not update themselves
brew cleanup
brew bundle dump --force --file ~/.dotfiles/Brewfile    # record the result, then commit it
```

- **Do not add `--greedy`.** It also upgrades the casks that update themselves, and one of those is
  `miniforge`: every conda environment lives inside it
  (`/opt/homebrew/Caskroom/miniforge/base/envs`), and a cask upgrade deletes that folder and installs a
  new one. The cask moves the environments aside and back, but that has not been tried here. Update
  conda with conda (`conda update -n base conda`).
- A major upgrade of `gcc`, `openblas`, `hdf5` or `boost` can break code compiled against the old one
  until it is rebuilt. Look for them in `brew outdated` first.
- `brew bundle check --file ~/.dotfiles/Brewfile` reports an installed but outdated package as unmet.
  That is a reminder to upgrade, not a missing package.

## A new Mac

1. `xcode-select --install` (the Command Line Tools are needed for Git and Homebrew).
2. `git clone https://github.com/tmnestor/.dotfiles.git ~/.dotfiles`. Start with `https`; switch to `ssh`
   at step 7.
3. Install Homebrew:

   ```zsh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

4. Read `Brewfile` and delete what is no longer wanted, then install the rest:

   ```zsh
   brew bundle --file ~/.dotfiles/Brewfile
   ```

5. Link the files into the home folder:

   ```zsh
   ln -s ~/.dotfiles/zshrc ~/.zshrc
   ln -s ~/.dotfiles/bashrc ~/.bashrc
   ln -s ~/.dotfiles/bash_profile ~/.bash_profile
   ln -s ~/.dotfiles/gitconfig ~/.gitconfig
   mkdir -p ~/.config && ln -s ~/.dotfiles/zsh ~/.config/zsh
   ```

6. Restart the terminal. `zsh -i -c exit` should print nothing.
7. [Generate an SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh), add it
   to GitHub and switch the remote:

   ```zsh
   # Generate the key in the default location (~/.ssh/id_ed25519)
   ssh-keygen -t ed25519 -C "101078845+tmnestor@users.noreply.github.com"

   # Start the ssh-agent and add the key to it and to the keychain
   eval "$(ssh-agent -s)"
   ssh-add --apple-use-keychain ~/.ssh/id_ed25519

   # Copy the public key, then add it at github.com > Settings > SSH and GPG keys
   pbcopy < ~/.ssh/id_ed25519.pub

   # Test the connection, and check the fingerprint and the user name it reports
   ssh -T git@github.com

   # Switch this repository from HTTPS to SSH
   git -C ~/.dotfiles remote set-url origin git@github.com:tmnestor/.dotfiles.git
   ```

   `~/.ssh/config` needs these lines for the key to be used and remembered:

   ```
   Host *
     AddKeysToAgent yes
     UseKeychain yes
     IdentityFile ~/.ssh/id_ed25519
   ```

Not kept here, and to be recreated by hand: `~/.zprofile` (it runs `brew shellenv`), `~/.zshenv`,
`~/.ssh/config` and `~/.condarc`.

## Before giving a Mac away

[Create a bootable USB installer for macOS](https://support.apple.com/en-us/HT201372).

Software audit:

- Uninstall unwanted software (GarageBand, iMovie, Keynote, Numbers, Pages and the like).
- Record what is installed: `brew bundle dump --force --file ~/.dotfiles/Brewfile`. Look in
  `/Applications` and `~/Applications` for anything Homebrew did not install.

Back up and sync:

- Commit and push every repository.
- Time Machine, Google Drive, and a manual copy on an external drive.
- Contacts, Photos, Calendar and Messages (Google, iCloud).

Deactivate licences and sign out:

- App Store (`Menu > Store > Sign Out`)
- iCloud, Google Drive and any application licensed to the machine
