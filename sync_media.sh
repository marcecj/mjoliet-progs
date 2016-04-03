#!/bin/sh

DIRS="/home/marcec/Media
/home/marcec/Music
/home/marcec/Other"
TARGET="/media/MARCEC_BACKUP/Informal/"
RSYNC_OPTIONS="-aX --exclude=lost+found/ --delete --delete-excluded --numeric-ids"
PRETEND=0
REMOTE=""

while getopts pr: a
do
    case $a in
        p) PRETEND=1;;
        r) REMOTE=$OPTARG;;
        *) echo "Invalid option \"$a\"" >&2;
            exit;;
    esac
done
shift $(expr $OPTIND - 1)

if [ -z "$REMOTE" -a ! -d "$TARGET" ]
then
    echo "Non-existent target!" >&2
    exit
fi

if [ -n "$REMOTE" ]
then
    ssh "$REMOTE" exit
    if [ $? != 0 ]; then
        echo "Unable to connect to host" >&2
        exit
    fi

    TARGET="$REMOTE:$TARGET"
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
