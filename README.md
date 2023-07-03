# Easy New Macbook Setup

💻📡🔨🚀🔥


```bash
#!/bin/bash

# Create SSH Key
test -f ~/.ssh/id_ed25519 | ssh-keygen -t ed25519 -C "timothy@fastmail.com" -f ~/.ssh/id_ed25519 -P ""

# Install Brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Brew Packages
brew install --cask anki sublime-text iterm2 hot monitorcontrol postman joplin transmission mark-text visual-studio-code firefox sabnzbd eloston-chromium && \
brew install docker wget zsh neofetch htop 

# Install Powerlevel10k theme - https://github.com/romkatv/homebrew-powerlevel10k
brew install romkatv/powerlevel10k/powerlevel10k && \
echo 'source $(brew --prefix powerlevel10k)/powerlevel10k.zsh-theme' >>! ~/.zshrc && \
brew update && brew upgrade


```
