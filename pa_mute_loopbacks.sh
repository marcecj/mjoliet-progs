#!/bin/sh

print_help() {
    cat <<- EOF
    $(basename $0): toggles the mute status of pulseaudio loopback outputs.

    Options:
     -d         Echo the command instead of executing it ("dry run").
     -v         Print more information on the source-output(s) being modified.
     -h         Display this help text.
EOF
    exit
}

while getopts hdv a;
do
    case $a in
        h) print_help;;
        d) dry_run=1;;
        v) verbose=1;;
    esac
done

pacmd list-source-outputs | grep "\(index\|driver\|muted\)" | while read l;
do
    if [ -n "$(echo $l|grep index)" ];
    then
        index=$(echo $l|cut -d' ' -f2)
        driver=
        muted=
        continue
    elif [ -n "$(echo $l|grep driver)" ];
    then
        driver=$(echo $l|cut -d\= -f2)
        continue
    elif [ -n "$(echo $l|grep muted)" ];
    then
        muted=$(echo $l|cut -d' ' -f2)
    fi

    if [ -n "$(echo $driver | grep loopback)" ];
    then
        if [ -n "$verbose" ];
        then
            if [ "$muted" = "no" ]; then
                action=mute
            else
                action=unmute
            fi

            echo "Found loop-back device to $action:"
            echo "  Index:  $index"
            echo "  Driver: $driver"
            echo "  Muted:  $muted"
        fi

        pa_cmd="pactl set-source-output-mute $index toggle"
        if [ -n "$dry_run" ]; then
            echo Would execute \"$pa_cmd\"
        else
            eval "$pa_cmd"
        fi
    fi
done
