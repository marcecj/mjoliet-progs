#!/bin/sh

# see http://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?part=1&chap=6
# TODO: finish
CROSSDEV_TREE="$HOME/crossdev"

mount -t proc none "$CROSSDEV_TREE"/proc
mount --rbind /dev "$CROSSDEV_TREE"/dev

sudo chroot "$CROSSDEV_TREE" /bin/bash
