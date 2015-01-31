#!/bin/sh

# Copyright (c) 2008-2011 Marc Joliet
#
# Creates ctags files for several languages.

LANGUAGES="C Make Python Sh tex Vim Lua matlab"
searchpaths="/usr/include
             /usr/local/include
             /usr/lib/python*/
             /usr/share/texmf-dist/
             /usr/share/awesome/lib/
             $HOME/.local/MATLAB/"

for path in $searchpaths
do
    if [ ! -d $path ]; then
        echo "Ignoring path '$path'"
        searchpaths=$(echo $searchpaths | sed s:"$path"::g)
        ignoredpath=1
    fi
done
searchpaths="${searchpaths} $(gcc-config -L | cut -d: -f1)"

[ "$ignoredpath" ] && echo

ctagspath=~/.vim/tags/

# --<lang>-kinds definitions
# see "ctags --list-kinds=<lang>"
# c and c++ have the same 'kinds'
cppkinds="+cdfmnpstuvx"
ckinds=$cppkinds
pythonkinds="+cfm"

if [ ! -d $ctagspath ]; then
  echo "$ctagspath:"
  echo "Not a directory! Please make it first."
  exit
fi

# Maybe add "--sort=foldcase"? Problem: vim requires "ignorecase".
options="-R --append=no --sort=foldcase --c-kinds=$ckinds --c++-kinds=$cppkinds --python-kinds=$pythonkinds --fields=+iaS --extra=+q"

echo "I am going to search in\n\n$(echo ${searchpaths} | tr ' ' '\n' | sed 's:\(.*\):\t\1:g')\n\nand save the tag files in ${ctagspath}.\n"
echo "I will use the following options: ${options}\n"

for lang in $LANGUAGES; do
  echo "Generating ctags for $lang..."
  /usr/bin/ctags $options --languages=$lang -f $ctagspath$(echo $lang | tr + p).tag $searchpaths
done

echo "Done!"
