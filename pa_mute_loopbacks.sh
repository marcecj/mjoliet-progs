#!/bin/sh

print_help() {
    cat <<- EOF
    $(basename $0): toggles the mute status of pulseaudio loopback streams.

    This command returns 1 when there are no loopback streams.

    Options:
     -d         Print the commands to be executed, do not run them ("dry run").
     -v         Print more information on the loopback stream(s) ("verbose").
     -h         Display this help text.
EOF
    exit
}

while getopts hdv a
do
    case $a in
        h) print_help;;
        d) dry_run=1;;
        v) verbose=1;;
    esac
done

if [ -n "$verbose" ]
then
    # get the output of pactl; append a single line containing "Source" in case
    # the last entry is a loopback stream, so that calculation doesn't fail
    pactl_out="$(pactl list source-outputs)\nSource"
fi

# This function limits the output of "pactl list source-outputs" to those lines
# belonging to the stream whose index matches the function's argument.
print_info() {
    index=$1

    # change $IFS so that the pipe operates line-wise when using echo
    local IFS='\n'

    num_lines=$(($(echo "$pactl_out" \
        | grep --line-number '^Source' \
        | grep -A1 "#$index" \
        | cut -d: -f1 | tac | tr '\n' ' ' \
        | xargs printf "%s - %s - 2")))

    echo "$pactl_out" \
        | grep -A$num_lines "#$index" \
        | sed "s:\(.*\):\t\1:"
}

indices=$(pactl list short source-outputs | grep module-loopback | cut -f1)

num_loopbacks=$(echo $indices | wc -w)
if [ "$num_loopbacks" -eq 0 ]
then
    echo "No loopback streams found!" >&2
    return 1
fi

if [ -n "$verbose" ]
then
    for l in $(seq $num_loopbacks)
    do
        index=$(echo $indices|cut -d' ' -f$l)
        echo "Loopback device #$l:"
        print_info $index
        echo
    done
fi

for index in $indices
do
    pa_cmd="pactl set-source-output-mute $index toggle"
    if [ -n "$dry_run" ]; then
        echo "$pa_cmd"
    else
        eval "$pa_cmd"
    fi
done
