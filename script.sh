#!/bin/bash


# ===== VARIABLES =====
USER="vader"          # mac username
SSH_PASSWORD=""       # optional
SSH_COMMENT="MacbookPro"        # optional
PROFILE_PIC_URL="https://preview.redd.it/darth-vader-4k-wallpapers-v0-8tz0elrqg8ha1.png?width=3840&format=png&auto=webp&v=enabled&s=54789bcc0c45e3de810e7328af3412f5b558bf48"
WALLPAPER_PIC_URL="https://preview.redd.it/darth-vader-4k-wallpapers-v0-50cuytjqg8ha1.png?width=3840&format=png&auto=webp&v=enabled&s=eec0cbbd3ba5bc6fcfe3e5d37b7a1d6d9e3cba8e"
BREW_APPS="docker tmux m-cli htop btop neofetch wget zsh ansible yt-dlp wireguard-tools"         
CASK_APPS="anki bitwarden sublime-text iterm2 hot monitorcontrol postman joplin transmission mark-text visual-studio-code firefox sabnzbd eloston-chromium"
# =====================

# Create SSH Key
test -f ~/.ssh/id_ed25519 || ssh-keygen -t ed25519 -C $SSH_COMMENT -f ~/.ssh/id_ed25519 -P $SSH_PASSWORD

# Install Brew
test -f /usr/local/bin/brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Brew Packages
brew install --cask $CASK_APPS && \
brew install $BREW_APPS

# Install Oh-My-ZSH + Powerlevel10k theme
test -f /usr/bin/xcodebuild || { xcode-select --install; printf "%s " "* Press enter to continue after xcode installed *" && read ans; }
rm -rf /Users/$USER/.oh-my-zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended" && \
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /Users/$USER/.oh-my-zsh/custom/themes/powerlevel10k && \
sed -i '' 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' /Users/$USER/.zshrc

brew update && brew upgrade

# wipe current profile picture
sudo dscl . delete /Users/$USER JPEGPhoto
sudo dscl . delete /Users/$USER Picture

wget $PROFILE_PIC_URL -O /Users/$USER/profile_pic.png

#set new profile picture
sudo dscl . create /Users/$USER Picture "/Users/$USER/profile_pic.png"

wget $WALLPAPER_PIC_URL -O /Users/$USER/wallpaper_pic.png

#set new wallpaper
#sudo osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/$USER/wallpaper_pic.png"'

