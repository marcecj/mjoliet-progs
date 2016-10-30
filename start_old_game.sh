#!/bin/sh

game="$1"

if [ ! -x "$(which "$game")" ]; then
    echo "\"$game\" not an executable. Quitting."
    exit
fi

echo "******************************************"
echo "Will now set max cpu frequency to minimum, to avoid speed problems."
echo "******************************************"

# Old games are too fast on modern computers, so throttle the CPU.
sudo /usr/bin/cpufreq-set -c 0 -u 1000MHz

echo
echo "Now starting \"$game\", have fun!"
echo

# Run the game on only one core.
taskset -c 0 "$game"

echo
echo "******************************************"
echo "Changing max cpu frequency back to maximum."
echo "******************************************"
echo

sudo /usr/bin/cpufreq-set -u 2200MHz
