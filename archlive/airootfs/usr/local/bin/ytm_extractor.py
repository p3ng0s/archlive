#!/usr/bin/python
# -*- coding: utf-8 -*-
# Made by papi
# ytm_extractor.py
# Description:
#  Downloads albu, covers from youtube music gallery
#  You need to extract all of the links using the network tab in inspector element
#  and then load all of your albums by scrolling down then extract the .har file
#  and run it through this script to download every album cover to a
#  youtube_music_artwork folder.

import urllib
import sys, json, os

data=None
inc=0

try:
    os.stat("./youtube_music_artwork")
except:
    os.mkdir("./youtube_music_artwork")
if len(sys.argv) != 2:
    print "Usage:"
    print "\t%s [file].har" % sys.argv[0]
    print
    print "Program made by papi to download artwork from .har files gathered from youtube music."
    sys.exit(-1)

with open(sys.argv[1], "r") as fp:
    data = json.load(fp)

for entrie in data["log"]["entries"]:
    for headers in entrie["response"]["headers"]:
        if headers["name"] == "content-type" and headers["value"] == "image/jpeg":
            print entrie["request"]["url"]
            urllib.urlretrieve(entrie["request"]["url"], "youtube_music_artwork/%d.jpg" % inc)
            inc+=1

