#!/bin/bash


set -e


echo "🤓  Running Instant Mac Script..."

# ===== VARIABLES =====
SSH_COMMENT="${USER}@$(hostname)"
BREW_APPS="docker tmux m-cli htop btop neofetch wget zsh ansible yt-dlp wireguard-tools"         
CASK_APPS="anki raycast bitwarden sublime-text iterm2 hot monitorcontrol postman joplin transmission mark-text visual-studio-code firefox sabnzbd eloston-chromium"
# =====================
i=0

#Check xcode installed
xcode-select --print-path &> /dev/null || { echo "⚠️  Script requires xcode tools to be installed. Run 'xcode-select --install'" && exit 1; }


#Check user is not root
if [ "$EUID" -eq 0 ]; then echo "⚠️  Please don't run directly as root. Use 'bash script.sh'" ; exit 1; fi


# 1. Create SSH Key
test -f ~/.ssh/id_ed25519 || \
  { echo -e "\n💻  Creating SSH Key" && \
    ssh-keygen -t ed25519 -C $SSH_COMMENT -f ~/.ssh/id_ed25519 -P "" &> /dev/null && \
      echo "✅  SSH Key Created Successfully" && \
        i=$((i+1)); }


# 2. Install Brew & Packages
test -f /usr/local/bin/brew || \
  { echo -e "\n💻  Installing Brew" && \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
      brew analytics off && \
        echo "✅  Brew Installed Successfully" && \
          echo -e "\n💻  Installing Brew Packages" && \
            brew install --quiet $BREW_APPS && \
              brew install --cask --quiet $CASK_APPS && \
                echo "✅  Brew Packages Installed Successfully" && \
                  i=$((i+1)); }


# 3. Install Oh-My-ZSH 
[ -d /Users/$USER/.oh-my-zsh ] || \
  { echo -e "\n💻  Installing Oh-My-ZSH" && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended" &> /dev/null && \
      echo "✅  Oh-My-ZSH Installed Successfully" && \
        i=$((i+1)); }


# 4. Install Powerlevel10k theme
[ -d /Users/$USER/.oh-my-zsh/custom/themes/powerlevel10k ] || \
  { echo -e "\n💻  Installing Powerlevel10k" && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /Users/$USER/.oh-my-zsh/custom/themes/powerlevel10k &> /dev/null && \
      sed -i '' 's/ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /Users/$USER/.zshrc && \
        echo "✅  Powerlevel10k Installed Successfully" && \
          i=$((i+1)); }


# 5. enable firewall
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep "Firewall is enabled. (State = 1)" &> /dev/null || \
  { echo -e "\n💻  Enabling Firewall" && \
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1 && \
      /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep "Firewall is enabled. (State = 1)" &> /dev/null && \
        echo "✅  Firewall Enabled Successfully" && \
          i=$((i+1)); }


if [ $i -eq 5 ]; then
  echo -e "\n\n\n🎆  Mission Success. Get ready for lift off..." && sleep 1
  echo "⏲️  Countdown begin..." && sleep 1
  echo "👨‍🚀  3" && sleep 1
  echo "👨‍🚀  2" && sleep 1
  echo "👨‍🚀  1" && sleep 1
  echo "🔥  Liftoff!!" && sleep 1
  echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥" && sleep 1
  echo "🚀🚀🚀🚀🚀🚀🚀🚀🚀🚀" && sleep 1
  echo "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥"
else
  echo -e "😬😬😬  Not everything completed successfully"
fi
