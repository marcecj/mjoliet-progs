#!/bin/sh

# a list of source/target pairs
DIRS="/home/marcec/Media /media/MARCEC_BACKUP/backups/Informal/
/home/marcec/Music /media/MARCEC_BACKUP/backups/Informal/
/home/marcec/Music/ /mnt/barry_data/Music/"
RSYNC_OPTIONS="-aX --one-file-system --exclude=lost+found/ --delete --delete-excluded --numeric-ids"
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
shift $((OPTIND - 1))

if [ -z "$REMOTE" ] && [ ! -d "$TARGET" ]
then
    echo "Non-existent target!" >&2
    exit
fi

if [ -n "$REMOTE" ]
then
    if ! ssh "$REMOTE" exit; then
        echo "Unable to connect to host" >&2
        exit
    fi
fi

[ $PRETEND -eq 1 ] && echo "Would execute:"

echo "$DIRS" | while read -r d;
do
    source="$(echo $d | cut -d' ' -f1)"
    target="$REMOTE:$(echo $d | cut -d' ' -f2)"

    echo "Backing up \"$source\" to \"$target\"."

    if [ ! -d "$source" ];
    then
        echo "Non-existent source!" >&2
        exit
    fi

    if [ $PRETEND -eq 1 ]
    then
        echo rsync "$RSYNC_OPTIONS" "$source" "$target"
    else
        rsync $RSYNC_OPTIONS "$source" "$target"
    fi
done
