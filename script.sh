#!/bin/bash



# ===== VARIABLES =====
SSH_COMMENT="${USER}@$(hostname)"
BREW_APPS="docker tmux m-cli htop btop neofetch wget zsh ansible yt-dlp wireguard-tools"         
CASK_APPS="anki raycast bitwarden sublime-text iterm2 hot monitorcontrol postman joplin transmission mark-text visual-studio-code firefox sabnzbd eloston-chromium"
# =====================


#Check xcode installed
xcode-select --print-path &> /dev/null || { echo "*** Script requires xcode tools to be installed. Run 'xcode-select --install' ***" && exit 1; }


#Check user is not root
if [ "$EUID" -eq 0 ]; then echo "*** Please don't run directly as root. Use 'bash script.sh' ***" ; exit 1; fi


# Create SSH Key
test -f ~/.ssh/id_ed25519 || \
  { echo -e "\n========== CREATE SSH KEY... ==========" && \
    ssh-keygen -t ed25519 -C $SSH_COMMENT -f ~/.ssh/id_ed25519 -P ""; }


# Install Brew
test -f /usr/local/bin/brew && brew update --quiet && brew upgrade --quiet
test -f /usr/local/bin/brew || \
  { echo -e "\n========== INSTALLING Brew... ==========" && \
    sudo -u $USER NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
      brew analytics off; }


# Install Brew Packages
echo -e "\n========== INSTALLING Brew Apps... ==========" && \
  brew install --quiet $BREW_APPS && \
  brew install --cask --quiet $CASK_APPS


# Install Oh-My-ZSH 
[ -d /Users/$USER/.oh-my-zsh ] || \
  { echo -e "\n========== INSTALLING Oh-My-ZSH... ==========" && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"; }


# Install Powerlevel10k theme
[ -d /Users/$USER/.oh-my-zsh/custom/themes/powerlevel10k ] || \
  { echo -e "\n========== INSTALLING Powerlevel10k... ==========" && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /Users/$USER/.oh-my-zsh/custom/themes/powerlevel10k && \
      sed -i '' 's/ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /Users/$USER/.zshrc; }


# enable firewall
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep "Firewall is enabled. (State = 1)" > /dev/null || \
  { echo -e "\n========== ENABLING FIREWALL... ==========" && \
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1 && \
      /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate; }
