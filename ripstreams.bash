#!/usr/bin/env bash
############################################################################
# Hacked together by Marc Joliet (marcec@gmx.de) as a learning experience. #
############################################################################
# This is a simple script to help automate ripping from streams via streamripper.
#
# How it works:
#
# Basically, it reads from an .m3u Playlist and - via awk - saves the element
# names and appropriate URLs to their own arrays. The lines of the names are
# also stored in their own array, to help in keeping normal files out. So:
#
#   $PUA = Playlist URL Array
#   $PLA = Playlist List Array
#   $PIA = Playlist Index Array
#     and...
#   $i_max = number of elements per array
#
# Furthermore, there's $FILE, which is the m3u file passed from the command
# line, and $DIR, which is where streamripper stores the stream.
#
# In the end, the user is prompted for his choice, which is the index of $PUA.
# The corresponding URL is passed along with $DIR to streamripper.
#
# TODO: Maybe check if the playlist file has the ending .m3u?
############################################################################

#
# set arguments
#

# Set Internal Field Seperator to <newline>. (for awk)
# IMPORTANT: This is needed for output of the Station names!!!
IFS=$'\n'

#save pLaylist to local variable, to evade Dr. Konfuzios.
FILE=$1

# Check if a Playlist file is given.
# If not, exit.
# The double brackets are needed to evaluate the expression correctly.
if [[ ! -r $FILE ]]; then
  echo -e "Please give me a readable file. It's not like I can read your mind.\n"
  exit
fi

# Now, set the directory to whatever is given.
# If no argument is passed, or argument is not a directory, default to $HOME.
if [[ -d "$2" ]]; then
  DIR="$2"
else
  DIR=$HOME
  echo -e "Not a directory, or no directory given. Will save stream to $HOME instead.\n"
fi

#
# create 'playlist'
#

# Save list of URLs.
# Done via awk magic.
PUA=($(awk -F"\n" /^http:/ "$FILE"))

# Save line no.s to array for later for-loop awesomeness :D.
PIA=($(awk -F"\n" '/^http:/ {print NR}' "$FILE"))

# Count words to set $i_max.
# Arrays start at 0, so subtract 1 from word count.
# NOTE: the double braces are needed for arithmetic expansion.
i_max=$(($(echo -e ${PUA[@]} | wc -w) - 1))

# Save list of station names to array.
for k in $(seq 0 $i_max); do
  PLA[$k]=$(awk -F"," "NR == ((${PIA[$k]}-1)) {print \$2}" "$FILE");
done

# Display the options:
echo -e "These are your choices:\n"
for k in $(seq 0 $i_max); do
  echo -e "$((k+1)).)\t${PLA[$k]}"
  echo -e "\t${PUA[$k]}\n"
done
echo -e "\n"

#
# execute streamripper
#

# read "choice" from stdin
echo "Please type in number of the station you want to rip:"
read -e choice

# Now set the URL.
URL=${PUA[(($choice-1))]}

echo -e "I will now start ripping from $URL and save it in $DIR.\n"

# 1st argument is the URL
# 2nd argument is the destination directory
# For more options, see "man streamripper" (well, duh).
/usr/bin/streamripper "$URL" -T -d "$DIR"
#EOF
