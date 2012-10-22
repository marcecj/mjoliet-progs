#!/bin/sh

# TODO: replace temp files with sed solution

print_help() {
    echo \
"Usage:
    $(basename $0) [options] [file_names]

Prepends a copyright comment to the top of the specified files.

Options:
-n|--name       each invocation adds a name to the list of copyright holders
-c|--comment    define the comment delimiter; each invocation overrides the previous
-h|--help       print current help
"
}

# option parsing by getopt(1)
opts=$(getopt --shell sh -o n:c:h --long name:,comment:,help -- "$@")
if [ $? != 0 ] ; then
    echo "Terminating..." >&2
    exit 1
fi
eval set -- "$opts"

while true; do
    case "$1" in
	-n|--name) shift;
        if [ -z "$names" ];
        then
            names="$1";
        else
            names="$names, $1";
        fi
        shift;;
    -c|--comment) shift; comment="$1"; shift;;
	-h|--help) print_help; exit;;
	--) shift; break;;
	*) echo $1 "ERROR!" ; exit 1;;
    esac
done

year=$(date +%Y);

ls -1 "$@" | while read i;
do
    # Only replace files if they don't contain the string "copyright"
    if [ -z "$(grep -i copyright "$i")" ];
    then
        echo "$comment Copyright (c) $year $names\n$comment See COPYING for licensing information.\n" \
        | cat - "$i" \
        | sponge > "$i"
    else
        echo "File $i already has copyright notice."
    fi
done
