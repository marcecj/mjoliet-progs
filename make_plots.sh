#!/bin/sh

# make_plots.sh (c) 2008-2009 Marc Joliet <marcec@gmx.de>
#
# This is a shell script I wrote to do batch conversions of graphics generated
# by other programs.  The target format is PDF and it is expected that all
# graphics are in a single directory (by default current). This is for use in
# conjunction with pdftex/luatex, which is what I use.
#
# Note that for gnuplot sed is used to filter lines containing "set term"
# without pdf and changes them to "set term pdf enhanced color".  If you run
# gnuplot yourself, you can pass the option "--no-gnuplot".
#
# This script makes use of Parameter Expansion, see 'man bash' for info if it
# hinders your ability to read the script.

# CHANGELOG:
#
# 20.04.2008:
#   Make it a bit more intelligent
# 08.07.2008:
#   added postscript for completions sake
# 04.08.2008:
#   Rewrote it to use switch/case, which is a) easier to read, b) more compact
#   and c) easier to further edit (i.e. add support for new filetypes).
#   Furthermore it now skips unaltered files. I also added a descrition and
#   -h/--help options.
# 06.08.2008
#   Added support for SVG, since 'convert' can convert it.
#   Also did a bit of cleanup.
# 07.08.2008
#   Yeah, changed the help output to be more legible. It was butt-ugly before...
# 10.09.2008
#   Fixed a small bug when creating the array $FILES (add a space up front)
# 16.11.2008
#   Made directory optional as first argument, default is current directory.
# 04.12.2008
#   Added --exact option to epstopdf, which might fix papersize problems with
#   some EPS files
# unknown
#   removed --exact option again, since it brought new problems to the table
# 15.03.2009
#   removed superfluous comments
# 15.06.2009
#   added IPE support
#   changed gnuplot case to use sed to change terminal type to pdf automatically
# 16.06.2009
#   added --no-gnuplot option for ignoring gnuplot scripts
#   now uses getopt(1) for option parsing
# 30.06.2009
#   made POSIX compatible
# 03.02.2011
#   convert all local variables to lower-case
#   support file names with spaces

filetypes="ps eps gpi svg ipe"

print_help() {
    cat << EOF
This program will check for the following filetypes:
  $filetypes
and convert them to PDF.

If you use gnuplot, you have two choices:
    1.)	  Let this script do the conversion for you.  "sed" is used to change
      any lines containing "set term" to "set term pdf enhanced color".
    2.)	  Run gnuplot yourself.  In this case, it may be useful to pass the
      "--no-gnuplot" option (see below).

Options:
  -h|--help	  This help text.
  --no-gnuplot	  Do not run gnuplot scripts.
EOF
exit;
}

# option parsing by getopt(1)
opts=$(getopt -o h --long no-gnuplot,help -- "$@")
if [ $? != 0 ] ; then
    print_help
    echo "Terminating..." >&2
    exit 1
fi
eval set -- "$opts"

while true; do
    case "$1" in
	--no-gnuplot) shift; echo "Ignoring gnuplot files."
	    filetypes=$(echo ${filetypes} | sed s/gpi//);;
	-h|--help)      print_help;;
	--) shift; break;;
	*) echo "ERROR!" ; exit 1;;
    esac
done

if [ -d "$1" ]; then
    dir="$1"
else
    echo "Directory \"$1\" does not exist, defaulting to current directory.\n"
    dir=.
fi

# The filetypes that we list in the current directory.
for fileext in $filetypes
do
    ls -1 "$dir"/*.$fileext 2>/dev/null | \
    while read fname
    do
        basename="${fname%.*}"

        if [ -f "$basename.pdf" ] && [ "${fname}" -ot "$basename.pdf" ]
        then
            echo "$fname has not been altered, skipping..."
            continue
        fi

        echo "Converting $fname to PDF..."
        case $fileext in
            gpi) cat "$fname" \
                | sed -e "/set term \(pdf\)\{0\}/ c\set term pdf enhanced color" \
                | sed -e "/set output/ d" \
                | gnuplot > "$basename.pdf";;
            eps) epstopdf "$fname";; # doesn't work with all eps files
            ps) ps2pdf14 "$fname";;
            # svg) convert "$fname" "$basename.pdf";;
            svg) inkscape --export-pdf="$basename.pdf" "$fname";;
            ipe) ipetoipe -pdf -export "$fname" "$basename.pdf";;
            *) echo "The mute has spoken! Something is amiss... What the hell kind of file is \"$fname\"?"
        esac
        if [ $? -eq "127" ]; then
            program_not_found=$(($program_not_found + 1))
        fi
    done
done

if [ "${program_not_found:-0}" -gt "0" ]; then
    echo "\nA program wasn't found at least $program_not_found time(s), make sure"
    echo "you have the following programs installed and in your \$PATH:"
    echo "gnuplot, epstopdf, ps2pdf[14], inkscape and ipetoipe."
fi

echo "\nDone!"
