#!/bin/sh

# export CDDBP_SERVER="freedb.freedb.org"
# export CDDBP_SERVER="us.cddb.com"

# rip using libparanoia, obtain cddb track info and rip everything into a big
# WAV file with a cue sheet
cdda2wav -paranoia -cddb 0 -t all -cuefile

# set split2flac options
out_pattern='@artist - {@year - }@album/@track - @title.@ext'
flac_opts="-8V"
# cdda2wav apparently by default creates latin1 encoded CUE sheets, and I can't
# see how to change that
split2flac_opts="-cue audio.cue -cuecharset latin1"

# split the wav file into multiple tagged FLAC files
split2flac audio.wav $split2flac_opts -e "$flac_opts" -of "$out_pattern"
