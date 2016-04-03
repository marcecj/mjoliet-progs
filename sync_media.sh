#!/bin/sh

DIRS="/home/marcec/Media
/home/marcec/Music
/home/marcec/Other"
TARGET="/media/MARCEC_BACKUP/Informal/"
RSYNC_OPTIONS="-aX --exclude=lost+found/ --delete --delete-excluded --numeric-ids"
PRETEND=0

while getopts p a
do
    case $a in
        p) PRETEND=1;;
        *) echo "Invalid option \"$a\"" >&2;
            exit;;
    esac
done
shift $(expr $OPTIND - 1)

if [ ! -d "$TARGET" ];
then
    echo "Non-existent target!" >&2
    exit
fi

echo "Target is \"$TARGET\"."

[ $PRETEND -eq 1 ] && echo "Would execute:"

echo "$DIRS" | while read d;
do
    if [ ! -d "$d" ];
    then
        echo "Non-existent source!" >&2
        exit
    fi

    if [ $PRETEND -eq 1 ]
    then
        echo rsync "$RSYNC_OPTIONS" "$d" "$TARGET"
    else
        rsync $RSYNC_OPTIONS "$d" "$TARGET"
    fi
done
