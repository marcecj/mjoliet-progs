#!/bin/sh

DIRS="/home/marcec/Media
/home/marcec/Music
/home/marcec/multimedia
/home/marcec/Other"
TARGET="/run/media/marcec/TOSHIBA EXT/marcec/"
RSYNC_OPTIONS="-aX --exclude=lost+found/ --delete --delete-excluded --numeric-ids"

if [ ! -d "$TARGET" ];
then
    echo "Non-existent target!"
    exit
fi

echo "$DIRS" | while read d;
do
    if [ ! -d "$d" ];
    then
        echo "Non-existent source!"
        exit
    fi

    # echo rsync "$RSYNC_OPTIONS" "$d" "$TARGET"
    rsync $RSYNC_OPTIONS "$d" "$TARGET"
done
