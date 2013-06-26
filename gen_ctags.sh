#!/bin/sh

# Copyright (c) 2008-2011 Marc Joliet

# Update ctags files for each language.
# This isn't as slow a motherfucker of a script as I had anticipated.
# I did, however, need an enormous $TMPDIR for sorting the C++ tags file.

# LANGUAGES="C Make Python Sh latex Vim Verilog Lua matlab"
LANGUAGES="C Make Python Sh tex Vim Verilog Lua matlab"
# add cpp_src for std namespace completion
searchpaths="/usr/include
             /usr/local/include
             $HOME/.vim/tags/cpp_src/
             /usr/lib/python*/
             /usr/share/texmf-dist/
             /usr/share/awesome/lib/
             /usr/local/matlab/"

for path in $searchpaths
do
    if [ ! -d $path ]; then
        echo "Ignoring path '$path'"
        searchpaths=$(echo $searchpaths | sed s:"$path"::g)
    fi
done

# This should hopefully expand to complete everything
# searchpaths+=" $(echo /usr/lib/gcc/x86_64-pc-linux-gnu/*/include)"
searchpaths="${searchpaths} $(gcc-config -L | cut -d: -f1)"

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

echo "I am going to search in\n$(echo ${searchpaths} | tr ' ' '\n') and save the tag files in ${ctagspath}!\n"
echo "I will use the following options: ${options}\n"

# NOTE: a dirty hack: since the C++ tags take up so much RAM, use the already
# enormous $PORTAGE_TMPDIR
#export TMPDIR="/var/tmp/portage/"

for lang in $LANGUAGES; do
  echo "Generating ctags for $lang..."
  /usr/bin/ctags $options --languages=$lang -f $ctagspath$(echo $lang | tr + p).tag $searchpaths
done

echo "Done!"
#EOF
