#!/bin/sh

if [ ! -f "$1" ]; then
    echo "You must specify an input file." >&2
    exit 1
fi

if [ -z "$2" ]; then
    echo "You must specify an output file." >&2
    exit 1
fi

# use ffmpeg to copy the audio and leave out any video streams
ffmpeg -i "$1" -c:a copy -vn "$2"
