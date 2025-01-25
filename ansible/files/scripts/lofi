#!/bin/bash


IMAGE_URL=https://media.tenor.com/1VEnfKkMGikAAAAd/lofi-girl-music.gif
MUSIC_URL=https://www.youtube.com/watch\?v\=jfKfPfyJRdk

# pre-requisities
which mpv > /dev/null || { echo "ERROR: mpv not installed" && exit 1; }
which imgcat > /dev/null || { echo "ERROR: imgcat not installed" && exit 1; }
if ! [ "$TERM_PROGRAM" = "iTerm.app" ]; then { echo "ERROR: terminal must be iTerm2" && exit 1; }; fi

imgcat --url $IMAGE_URL && mpv --no-video --really-quiet $MUSIC_URL
