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
ansible-playbook -e "ansible_become_password=$MY_PASSWORD" main.yml

# re-source brew environment
eval "$(/opt/homebrew/bin/brew shellenv)" && echo "✅ Homebrew Environment re-sourced"

# Switch git from HTTPS to SSH
git remote set-url origin "git@github.com:oregonpillow/instant-mac.git" && \
echo "✅ Updated 'oregonpillow/instant-mac.git' repo to SSH Authentication"

cd $HOME

yadm remote set-url origin "git@github.com:oregonpillow/dotfiles.git" && \
echo "✅ Updated 'oregonpillow/dotfiles.git' repo to SSH to Authentication"


# Write iTerm conf
defaults write com.googlecode.iterm2 PrefsCustomFolder "$HOME/.iterm2"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder true
defaults write -g com.apple.swipescrolldirection -bool false
defaults write com.apple.finder AppleShowAllFiles true && killall Finder
echo $MY_PASSWORD | sudo -S reboot > /dev/null 2>&1
