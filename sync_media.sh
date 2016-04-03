#!/bin/sh

DIRS="/home/marcec/Media
/home/marcec/Music
/home/marcec/Other"
TARGET="/media/MARCEC_BACKUP/Informal/"
RSYNC_OPTIONS="-aX --exclude=lost+found/ --delete --delete-excluded --numeric-ids"

if [ ! -d "$TARGET" ];
then
    echo "Non-existent target!" >&2
    exit
fi

echo "$DIRS" | while read d;
do
    if [ ! -d "$d" ];
    then
        echo "Non-existent source!" >&2
        exit
    fi

    # echo rsync "$RSYNC_OPTIONS" "$d" "$TARGET"
    rsync $RSYNC_OPTIONS "$d" "$TARGET"
done
