# dotfiles

I ***learned*** about dotfiles at [Udemy](https://www.udemy.com/course/dotfiles-from-start-to-finish-ish/?referralCode=445BE0B541C48FE85276).

## Decommission Computer

[Create a bootable USB installer for macOS](https://support.apple.com/en-us/HT201372).

Software audit:
- Uninstall unwanted software (e.g. GarageBand, iMovie, Keynote, Numbers, Pages)
- Install missing software (look at `/Applications`, panes in System Preferences , maybe `~/Applications`, etc.)

Backup / sync files:
- Commit and Push to remote repositories
- Run `code --list-extensions > vscode_extensions` from `~/.dotfiles` to export [VS Code extensions](vscode_extensions)
- Time Machine
- Dropbox / Google Drive
- Manual Backups (external drives, redundant cloud services)
- Contacts, Photos, Calendar, Messages (Google, iCloud)
- etc.

Deactivate licenses:
- Dropbox (`Preferences > Account > Unlink`)
- ScreenFlow (`Preferences > Licenses > Deactivate`)
- Sign Out of App Store (`Menu > Store > Sign Out`)
- iTunes, etc.


## Restore Instructions

1. `xcode-select --install` (Command Line Tools are required for Git and Homebrew)
2. `git clone https://github.com/tmnestor/.dotfiles.git ~/.dotfiles`. Start with `https` but switch to `ssh` after everything is installed.
3. `cd ~/.dotfiles`
4. If necessary, `git checkout <another_branch>`.
5. Do one last Software Audit by editing [Brewfile](Brewfile) directly.
6. [`./install`](install)
7. Restart computer.
8. Setup up Dropbox (use multifactor authentication!) and allow files to sync before setting up dependent applications. Alfred settings are stored here. Mackup depends on this as well (and thus so do Terminal and VS Code).
9. Run `mackup restore`. Consider doing a `mackup restore --dry-run --verbose` first.
10. [Generate ssh key](https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh), add to GitHub, and switch remotes.

    ```zsh
    # Generate SSH key in default location (~/.ssh/config)
    ssh-keygen -t rsa -b 4096 -C "101078845+tmnestor@users.noreply.github.com"

    # Start the ssh-agent
    eval "$(ssh-agent -s)"

    # Create config file with necessary settings
    << EOF > ~/.ssh/config
    Host *
      AddKeysToAgent yes
      UseKeychain yes
      IdentityFile ~/.ssh/id_rsa
    EOF

    # Add private key to ssh-agent 
    ssh-add -K ~/.ssh/id_rsa

    # Copy public key and add to github.com > Settings > SSH and GPG keys
    pbcopy < ~/.ssh/id_rsa.pub

    # Test SSH connection, then verify fingerprint and username
    # https://help.github.com/en/github/authenticating-to-github/testing-your-ssh-connection
    ssh -T git@github.com

    # Switch from HTTPS to SSH
    git remote set-url origin git@github.com:tmnestor/.dotfiles.git
    ```
## Create symlinks in the Home directory to the real files in the repo.

```zsh
# There are better and less manual ways to do this;
# investigate install scripts and bootstrapping tools.

ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
```


## Install Homebrew, followed by the software listed in the Brewfile.

```zsh
# These could also be in an install script.

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Then pass in the Brewfile location...
brew bundle --file ~/.dotfiles/Brewfile

# ...or move to the directory first.
cd ~/.dotfiles && brew bundle
```





