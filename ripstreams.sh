#!/bin/sh

print_usage() {
    cat <<- EOF
Usage:
  $(basename $0) playlist.m3u [output_directory]
EOF
exit
}

streamripper=$(which streamripper 2>/dev/null)

if [ ! -x "$streamripper" ]
then
    echo "streamripper is not installed! Aborting"
    exit
fi

fname="$1"
if [ ! -r "$fname" ]
then
    print_usage
fi

if [ -d "$2" ]
then
    dir="$2"
else
    dir="$HOME"
    echo "*** Not a directory, or no directory given. Will save stream to $HOME instead.\n"
fi

grep ^http: $fname | {
k=1
while read url
do
    name=$(grep -B1 "$url" $fname|tail -n2|head -n1)
    name=${name#*,}

    urls="$urls$url\n"
    names="$names$name\n"

    echo "${k}.)\t$name\n\t$url\n"
    k=$(($k+1))
done

read -p "Please type in the number of the station you want to rip: " choice <&1

url=$(echo $urls | head -n$choice | tail -n1 | tr '\r\n' '\0')

echo "$streamripper $url -T -d $dir\n"
$streamripper $url -T -d $dir
}
