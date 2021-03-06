#!/bin/sh

print_usage() {
    cat <<- EOF
Usage:
  $(basename "$0") playlist.m3u [output_directory] [streamripper_flags [streamripper_flags]]
EOF
exit
}

streamripper=$(which streamripper 2>/dev/null)

if [ ! -x "$streamripper" ]
then
    echo "streamripper is not installed! Aborting"
    exit
fi

if [ -r "$1" ]
then
    fname="$1"; shift
else
    print_usage
fi

if [ -d "$1" ]
then
    dir="$1"; shift
else
    dir="$HOME"
    echo "*** Not a directory, or no directory given. Will save stream to $HOME instead."
    echo
fi

grep ^http: "$fname" | {
k=1
while read -r url
do
    name=$(grep -B1 "$url" "$fname"|tail -n2|head -n1)
    name=${name#*,}

    urls="$urls$url\n"
    names="$names$name\n"

    printf "%i.)\t%s\n\t%s" "${k}" "$name" "$url"
    k=$((k+1))
done

read -r -p "Please type in the number of the station you want to rip: " choice <&1

url=$(echo "$urls" | head -n"$choice" | tail -n1 | tr '\r\n' '\0')

# any leftover arguments are passed to streamripper verbatim
echo "$streamripper $url -T -d $dir $*"
echo
$streamripper "$url" -T -d "$dir" "$@"
}
