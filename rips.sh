#!/bin/sh

# export CDDB_SERVER="freedb.freedb.org"
# export CDDB_SERVER="us.cddb.com"

# rip using libparanoia, obtain cddb track info and rip everything into a big
# WAV file with a cue sheet
cdda2wav -paranoia -cddb 0 -t all -cuefile

# set split2flac options
out_pattern='@artist - {@year - }@album/@track - @title.@ext'
flac_opts="-8V"

# split the wav file into multiple tagged FLAC files; force bash due to bashisms
split2flac.sh audio.wav -cue audio.cue -e "$flac_opts" -of "$out_pattern"
