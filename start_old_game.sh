#!/bin/sh

game="$1"

if [ ! -x "$(which $game)" ]; then
    echo "\"$game\" not an executable. Quitting."
    exit
fi

echo "******************************************"
echo "Will now set max cpu frequency to minimum, to avoid speed problems."
echo "******************************************\n"

# Old games are too fast on modern computers, so throttle the CPU.
sudo /usr/bin/cpufreq-set -u 1000MHz

echo "Now starting \"$game\", have fun!\n"

# Run the game on only one core.
taskset -c 0 $game

echo "\n******************************************"
echo "Changing max cpu frequency back to maximum."
echo "******************************************\n"

sudo /usr/bin/cpufreq-set -u 2200MHz
