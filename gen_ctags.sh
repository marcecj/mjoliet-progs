#!/bin/sh

# Copyright (c) 2008-2015 Marc Joliet
#
# Creates ctags files for several languages.

LANGUAGES="C Make Python Sh tex Vim Lua matlab"
searchpaths="/usr/include
             /usr/local/include
             /usr/lib64/python*/
             /usr/share/texmf-dist/
             /usr/share/octave/
             /usr/share/vim/
             $HOME/octave*/"

for path in $searchpaths
do
    if [ ! -d "$path" ]; then
        echo "Ignoring path '$path'"
        searchpaths=$(echo "$searchpaths" | sed "s:$path::g")
        ignoredpath=1
    fi
done
searchpaths="${searchpaths} $(gcc-config -L | cut -d: -f1)"

[ "$ignoredpath" ] && echo

ctagspath=~/.vim/tags/

# --<lang>-kinds definitions
# see "ctags --list-kinds=<lang>"
ckinds="+px"
cppkinds="${ckinds}"

if [ ! -d $ctagspath ]; then
  echo "$ctagspath:"
  echo "Not a directory! Please make it first."
  exit
fi

# Maybe add "--sort=foldcase"? Problem: vim requires "ignorecase".
options="-R --append=no --sort=foldcase --kinds-c=$ckinds --kinds-c++=$cppkinds --fields=+iaS --extras=+q"

echo "I am going to search in"
echo
echo ${searchpaths} | tr ' ' '\n' | sed 's:\(.*\):\t\1:g'
echo
echo "and save the tag files in ${ctagspath}."
echo
echo "I will use the following options: ${options}"
echo

for lang in $LANGUAGES; do
  echo "Generating ctags for $lang..."
  /usr/bin/ctags $options --languages="$lang" -f "$ctagspath$(echo "$lang" | tr + p)".tag $searchpaths
done

echo "Done!"
