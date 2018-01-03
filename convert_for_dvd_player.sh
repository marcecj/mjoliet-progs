#!/bin/sh

# This is a simple shell script that uses ffmpeg to convert video files to a
# format suitable for playback via USB stick on my Mother's DVD player (which
# only supports PAL DivX files).

if [ $# -eq 0 ]
then
    echo >&2 "Missing argument, specify at least one file name."
    exit 1
fi

for f in "$@"
do
    ffmpeg -i "$f" \
        -c:v mpeg4 -c:a libmp3lame \
        -q:v 3 -q:a 3 \
        -tag:v xvid \
        # 25 FPS for PAL
        -r 25 \
        # use 702 pixels because of upscaling to 720 pixels (see, e.g.,
        # https://de.wikipedia.org/wiki/ITU-R_BT_601)
        -vf "scale=702:576" \
        "$f.avi"
done
