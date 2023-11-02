#!/bin/bash


set -e

# ===== VARIABLES =====
SSH_COMMENT="${USER}@$(hostname)"
BREW_APPS="tmux asciinema m-cli htop btop neofetch wget zsh ansible yt-dlp wireguard-tools mpv aicommits restic wifi-password"         
CASK_APPS="anki tabby skype tunnelblick docker rectangle raycast bitwarden spotify sublime-text iterm2 hot monitorcontrol postman joplin transmission-remote-gui mark-text visual-studio-code librewolf sabnzbd eloston-chromium microsoft-remote-desktop amethyst oversight betterdisplay alt-tab unclack mic-drop pomatez"
# =====================
i=0

# Disable Mission Control "Automatically rearrange Spaces based on most recent use", since it conflicts with amethyst
defaults write com.apple.dock "mru-spaces" -bool "false" && killall Dock

#Check xcode installed
xcode-select --print-path &> /dev/null || { echo "⚠️  Script requires xcode tools to be installed. Run 'xcode-select --install'" && exit 1; }

#Check user is not root
if [ "$EUID" -eq 0 ]; then echo "⚠️  Please don't run directly as root. Use 'bash script.sh'" ; exit 1; fi

echo "👌  Preflight checks complete"
echo "🤓  Hold on tight..."

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
            brew install --no-quarantine --quiet $BREW_APPS && \
              brew install --no-quarantine --cask --quiet $CASK_APPS && \
                echo "✅  Brew Packages Installed Successfully" && \
                  i=$((i+1)); }


# 3. Install Oh-My-Zsh 
[ -d /Users/$USER/.oh-my-zsh ] || \
  { echo -e "\n💻  Installing Oh-My-Zsh" && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended" &> /dev/null && \
      echo "✅  Oh-My-Zsh Installed Successfully" && \
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
elif [ $i -eq 0 ]; then
  echo -e "\n\n\n 👍👍👍 Looks like everything is already done"
else
  echo -e "\n\n\n😬😬😬  Not everything completed successfully"
fi
