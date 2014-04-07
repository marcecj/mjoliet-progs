#!/usr/bin/env python

import os
import argparse
from subprocess import check_call


def get_line_pairs(fname):

    lines = []
    try:
        with open(fname) as f:
            lines = [l.strip() for l in f]
    except UnicodeError as e:
        print("Error:", e)
        exit("The playlist ought to be UTF-8 encoded!")

    # remove the first
    lines.pop(0)
    return list(zip(lines[::2], lines[1::2]))

if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description="Select a stream from an M3U playlist and rip it."
    )

    parser.add_argument(
        "playlist",
        metavar="playlist.m3u",
        help="An M3U playlist with some stream URLs in it."
    )

    parser.add_argument(
        "directory",
        nargs='?',
        default=os.path.expanduser("~"),
        help="The directory in which to store the rip."
    )

    args, streamripper_flags = parser.parse_known_args()

    line_pairs = get_line_pairs(args.playlist)

    for i, l in enumerate(line_pairs):
        title, url = l
        title = title.partition(',')[-1]
        print("{:>2}.) {}\n     {}\n".format(i+1, title, url))

    choice = int(input("Type in the number of the station to rip: ")) - 1
    url = line_pairs[choice][1]

    try:
        streamripper_cmd = ["streamripper", url, "-d", args.directory]
        streamripper_cmd.extend(streamripper_flags)

        print('Executing "' + ' '.join(streamripper_cmd) + '"')

        check_call(streamripper_cmd)
    except CalledProcessError as e:
        print("Error calling streamripper:", e)
        exit()
