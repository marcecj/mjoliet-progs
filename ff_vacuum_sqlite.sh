#!/bin/sh
find ~/.mozilla/firefox/ -iname \*.sqlite -exec sqlite3 \{\} "vacuum;" \;
