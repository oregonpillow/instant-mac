#!/bin/sh

# dependencies: brew install blueutil

# https://apple.stackexchange.com/questions/219885/use-caffeinate-to-prevent-sleep-on-lid-close-on-battery

# collect status
CLAMCLOSED=$(/usr/sbin/ioreg -r -k AppleClamshellState -d 4 | grep -q '"AppleClamshellState" = Yes' && echo "true" || echo "false")
BLUEOFF=$(/usr/sbin/system_profiler SPBluetoothDataType | grep -q "State: Off" && echo "true" || echo "false")
WIFIOFF=$(/usr/sbin/networksetup -getairportpower en0 | grep -q "Wi-Fi Power (en0): Off" && echo "true" || echo "false")
MUTED=$(/usr/bin/osascript -e "output muted of (get volume settings)")

# disable sleep, otherwise script will not run when state is: battery + clamshell
sudo /usr/bin/pmset -b disablesleep 1

    
if [ $CLAMCLOSED = "true" ]; then

  # disable bluetooth
  if [ $BLUEOFF = "false" ]; then
    /opt/homebrew/bin/blueutil --power 0        
  fi

  # disable wifi
  if [ $WIFIOFF = "false" ]; then
    /usr/sbin/networksetup -setairportpower en0 off
  fi

  # mute sound
  if [ $MUTED = "false" ]; then
    /usr/bin/osascript -e "set volume with output muted"
  fi

  # enable sleep
  sudo /usr/bin/pmset -b disablesleep 0

fi
