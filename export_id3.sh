#!/bin/sh

print_help() {
    echo "$(basename "$0"): prints id3 tags to STDOUT in an OGG Vorbis Comment compatible format."
    echo
    echo "When a tag has no Vorbis Comment equivalent, it is exported verbatim. Pictures are currently not exported."
    echo "If the second argument is a file, metaflac is called on the file instead of printing tags."
    exit
}

case $1 in
    "-h"|"--help")
        print_help
        ;;
    *) file="$1"
        ;;
esac

if [ ! -z "$2" ]; then
    if [ -f "$2" ]; then
        flacfile="$2"
    else
        echo "File '$2' non-existent."
        exit
    fi
fi

# Some regex magic: convert id3info's verbose output to a TAG=VALUE pair.  This
# is then piped into a code block and processed.  The code block is necessary
# because without it variables like $metaflaccmd would be unaltered after the
# loop since the pipes spawn subprocesses that don't affect the parent
# environment.
id3info "$file" | grep "===" | sed 's/=== \(.*\) (.*): \(.*\)/\1=\2/g' | {
while read -r curtag
do
    tagname="${curtag%%=*}"
    tagval="${curtag#*=}"

    # TODO: implement more tags (see http://en.wikipedia.org/wiki/Id3#ID3v2)
    case $tagname in
        TALB)           flactag=ALBUM;;
        TPE1|TCOM)      flactag=ARTIST;;
        TPE2|TPE3|TPE4) flactag=PERFORMER;;
        TCOP)           flactag=COPYRIGHT;;
        TDAT|TYER)      flactag=DATE;;
        TCON)           flactag=GENRE;;
        TIT2)           flactag=TITLE;;
        TRCK)           flactag=TRACKNUMBER;;
        COMM)           flactag=DESCRIPTION;;
		APIC) echo 'INFO: picture export not implemented.' >&2;;
        *)
            echo "INFO: unknown tag '$tagname' being exported verbatim." >&2
            flactag=$tagname
            ;;
    esac

    # if unset, the tag should not be printed
    if [ ! -z "$flactag" ]
    then
        if [ -z "$flacfile" ]
        then
            echo "$flactag=$tagval"
        else
            metaflaccmd="$metaflaccmd --set-tag=$flactag=\"$tagval\""
        fi
    fi

    # clear for next run
    flactag=
done

if [ ! -z "$metaflaccmd" ] && [ ! -z "$flacfile" ]
then
    # echo metaflac $metaflaccmd "\"$flacfile"\"
    eval metaflac "$metaflaccmd" "\"$flacfile\""
fi
}
