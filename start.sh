#!/bin/bash

#Check xcode installed
xcode-select --print-path &>/dev/null || { echo "⚠️  Script requires xcode tools to be installed. Run 'xcode-select --install'" && exit 1; }

#Check user is not root
if [ "$EUID" -eq 0 ]; then
  echo "⚠️  Please don't run directly as root. Use 'bash start.sh'"
  exit 1
fi

START_TIME="$(date)"

# Prompt for password - needed for some ansible tasks and to install brew
read -sp "Enter your sudo password: " MY_PASSWORD
export MY_PASSWORD
# this is needed to init a sudo session
echo $MY_PASSWORD | sudo -S echo "🔑  sudo session started"


# Change Finder Settings 
defaults write com.apple.finder AppleShowAllFiles true && killall Finder


# Install Brew
{ test -f /opt/homebrew/bin/brew && echo "✅  Brew already Installed"; } \
  || { echo -e "\n💻  Installing Brew" \
    && NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    && echo "✅  Brew Installed Successfully"; }

# Add Brew to PATH
test -f ~/.zprofile || touch ~/.zprofile
{ grep --silent 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile \
  || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile; }
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install Ansible
which ansible > /dev/null 2>&1 && echo "✅  Ansible already Installed" \
  || { echo -e "\n💻  Installing Ansible" \
    && brew analytics off \
    && brew install --no-quarantine --quiet ansible \
    && echo "✅  Ansible Installed Successfully"; }

# Use ansible for the rest
cd ansible
#ansible-galaxy install -r requirements.yml
ansible-playbook -e "ansible_become_password=$MY_PASSWORD" main.yml


# Install oh-my-zsh (needs zsh, should be installed after brew zsh installed)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"

# re-source brew environment
eval "$(/opt/homebrew/bin/brew shellenv)" && echo "✅Homebrew Environment re-sourced"

# Install dotfiles
echo "🔧  Installing dotfiles"
cd $HOME
yadm clone -f --no-bootstrap https://github.com/oregonpillow/dotfiles.git && \
# Pause section
echo "Press Enter to decrypt sensitive config files..."
read
yadm decrypt || { echo "⚠️  Failed to decrypt config files. Exiting..." && exit 1; }

# Switch from HTTPS to SSH
yadm remote set-url origin "git@github.com:oregonpillow/dotfiles.git" && \
echo "✅ Updated 'oregonpillow/dotfiles.git' repo to SSH to Authentication"

cd instant-mac
git remote set-url origin "git@github.com:oregonpillow/instant-mac.git" && \
echo "✅ Updated 'oregonpillow/instant-mac.git' repo to SSH Authentication"

# Set iTerm2 config
system_type=$(uname -s)
if [ "$system_type" = "Darwin" ]; then
  # possibly add something here to ensure iTerm2 is installed using Homebrew
  # cask like in the previous example
  if [ -d "$HOME/.iterm2" ]; then
    echo "Setting iTerm preference folder"
    defaults write com.googlecode.iterm2 PrefsCustomFolder "$HOME/.iterm2"
  fi
fi

# execution time
END_TIME="$(date)"
echo "🕒  Script started at: $START_TIME"
echo "🕒  Script ended at: $END_TIME"
