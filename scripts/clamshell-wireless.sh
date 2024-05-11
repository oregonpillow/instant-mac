#!/bin/sh

# dependencies: brew install blueutil

# collect status
CLAMCLOSED=$(/usr/sbin/ioreg -r -k AppleClamshellState -d 4 | grep -q '"AppleClamshellState" = Yes' && echo "true" || echo "false")
BLUEOFF=$(/usr/sbin/system_profiler SPBluetoothDataType | grep -q "State: Off" && echo "true" || echo "false")
WIFIOFF=$(/usr/sbin/networksetup -getairportpower en0 | grep -q "Wi-Fi Power (en0): Off" && echo "true" || echo "false")
MUTED=$(/usr/bin/osascript -e "output muted of (get volume settings)")
    
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

fi
