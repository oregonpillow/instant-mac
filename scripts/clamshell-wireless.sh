#!/bin/sh

# dependencies: brew install blueutil

# collect statuses
CLAMCLOSED=$(/usr/sbin/ioreg -r -k AppleClamshellState -d 4 | grep -q '"AppleClamshellState" = Yes' && echo "true" || echo "false")
BLUEOFF=$(/usr/sbin/system_profiler SPBluetoothDataType | grep -q "State: Off" && echo "true" || echo "false")
WIFIOFF=$(/usr/sbin/networksetup -getairportpower en0 | grep -q "Wi-Fi Power (en0): Off" && echo "true" || echo "false")
MUTED=$(/usr/bin/osascript -e "output muted of (get volume settings)")
SLEEPOFF=$(sudo pmset -g | grep "SleepDisabled" | grep -q -o -E '[1]' && echo "true" || echo "false")

# disable sleep, otherwise script will not run when state is: battery + clamshell
# *** this also means  you should close the lid when on battery and want to enable sleep ***
if [ $SLEEPOFF = "false" ]; then
  sudo /usr/bin/pmset -b disablesleep 1
fi


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

  # re-enable sleep mode
  sudo /usr/bin/pmset -b disablesleep 0

fi
