#!/bin/sh

print_usage() {
    cat <<- EOF
    $(basename $0) [-n <num>] [-d] [-h] [<dir>]

    This program prints the largest <num> regular files/directories
    in the current directory. <dir> defaults to the current directory.

    Options:
     -n <num>     Print top <num> entries (default: 20).
     -d           Only print dotfiles.
     -h           Display this help text.
EOF
    exit
}

n=20
findopts="-maxdepth 1 -mindepth 1"
duopts="--files0-from=- -hsc"

while getopts n:dh a;
do
    case $a in
        n) n=$OPTARG;;
        d) findopts="$findopts -iname .\*";;
        h) print_usage;;
        *) echo "\nUsage:\n"
            print_usage;;
    esac
done
shift $(expr $OPTIND - 1)

dir=.
if [ -n "$1" ]; then
    dir="$1"
fi

lscommand="find \"$dir\" $findopts"
echo "Directory is \"$dir\""
echo "Command is \"$lscommand\""
echo

# List files, one step per line:
# 1.) create list of null-delimited files
# 2.) first pass through du, sort output
# 3.) grab the top $n files, null-delimited
# 4.) second pass through du
eval $lscommand -print0 \
| du $duopts 2>/dev/null | sort -hr \
| head -n$(($n+1)) | tail -n$n | cut -f2 | tr "\n" "\0" \
| du $duopts 2>/dev/null
