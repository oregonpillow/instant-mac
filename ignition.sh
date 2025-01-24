#!/bin/bash


set -e

# ===== VARIABLES =====
HOSTNAME="macbook"
SSH_COMMENT="${USER}@$HOSTNAME"
BREW_APPS="tmux sshs asciinema m-cli htop btop neofetch wget zsh ansible yt-dlp wireguard-tools mpv aicommits restic wifi-password"         
CASK_APPS="anki balenaetcher tabby skype tunnelblick docker rectangle raycast bitwarden spotify sublime-text iterm2 hot monitorcontrol postman joplin transmission-remote-gui mark-text visual-studio-code librewolf sabnzbd eloston-chromium microsoft-remote-desktop amethyst oversight betterdisplay alt-tab unclack mic-drop pomatez"
# =====================

# Disable Mission Control "Automatically rearrange Spaces based on most recent use", since it conflicts with amethyst
sudo defaults write com.apple.dock "mru-spaces" -bool "false" && killall Dock

#Check xcode installed
xcode-select --print-path &> /dev/null || { echo "⚠️  Script requires xcode tools to be installed. Run 'xcode-select --install'" && exit 1; }

#Check user is not root
if [ "$EUID" -eq 0 ]; then echo "⚠️  Please don't run directly as root. Use 'bash script.sh'" ; exit 1; fi

echo "👌  Preflight checks complete"

# 1. Create SSH Key
test -f ~/.ssh/id_ed25519 || \
  { echo -e "\n💻  Creating SSH Key" && \
    ssh-keygen -t ed25519 -C $SSH_COMMENT -f ~/.ssh/id_ed25519 -P "" &> /dev/null && \
      echo "✅  SSH Key Created Successfully" && \
        sed -i '' 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
          sed -i '' 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
            echo "✅  SSH Config Hardened"; }


# 2. Install Brew & Packages
test -f /usr/local/bin/brew || \
  { echo -e "\n💻  Installing Brew" && \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
      brew analytics off && \
        echo "✅  Brew Installed Successfully" && \
          echo -e "\n💻  Installing Brew Packages" && \
            brew install --no-quarantine --quiet $BREW_APPS && \
              brew install --no-quarantine --cask --quiet $CASK_APPS && \
                brew tap homebrew/cask-fonts && brew install font-hack-nerd-font && \
                  echo "✅  Brew Packages Installed Successfully"; }


# 3. Install Oh-My-Zsh 
[ -d /Users/$USER/.oh-my-zsh ] || \
  { echo -e "\n💻  Installing Oh-My-Zsh" && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended" &> /dev/null && \
      echo "✅  Oh-My-Zsh Installed Successfully"; }


# 4. Install Powerlevel10k theme
[ -d /Users/$USER/.oh-my-zsh/custom/themes/powerlevel10k ] || \
  { echo -e "\n💻  Installing Powerlevel10k" && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /Users/$USER/.oh-my-zsh/custom/themes/powerlevel10k &> /dev/null && \
      sed -i '' 's/ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /Users/$USER/.zshrc && \
        echo "✅  Powerlevel10k Installed Successfully"; }


# 5. enable firewall
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep --silent "Firewall is enabled. (State = 1)" &> /dev/null || \
  { echo -e "\n💻  Enabling Firewall" && \
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1 && \
      /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep --silent "Firewall is enabled. (State = 1)" &> /dev/null && \
        echo "✅  Firewall Enabled Successfully" && \
          sudo systemsetup -setremotelogin on > /dev/null && sudo systemsetup -getremotelogin | grep --silent "Remote Login: On" && \
            echo "✅  SSH Server Enabled Successfully" && \
              sudo systemsetup -setwakeonnetworkaccess on > /dev/null 2>&1 && sudo systemsetup -getwakeonnetworkaccess | grep --silent "Wake On Network Access: On" && \
                echo "✅  Wake-on-Network Enabled Successfully" && \
                  sudo scutil --set HostName $HOSTNAME && sudo scutil --get HostName | grep --silent $HOSTNAME && \
                    sudo scutil --set LocalHostName $HOSTNAME && sudo scutil --get LocalHostName | grep --silent $HOSTNAME && \
                      sudo scutil --set ComputerName $HOSTNAME && sudo scutil --get ComputerName | grep --silent $HOSTNAME && \
                        sudo dscacheutil -flushcache && \
                          echo "✅  Hostname Updated Successfully"; }
