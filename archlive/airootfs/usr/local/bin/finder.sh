#!/bin/bash
# finder.sh
# Created on: Sun 07 Nov 2021 02:04:48 AM GMT
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  A script to run for the search functionality to work :)
# Configure:
#  set this cronjob:
#   0 */3 * * * sh /usr/local/bin/finder.sh

DIR_LIST_FILE=/tmp/dirlist
USER=p4p1

find /home/$USER/Desktop/ > $DIR_LIST_FILE
find /home/$USER/Downloads/ >> $DIR_LIST_FILE
find /home/$USER/Documents/Books >> $DIR_LIST_FILE
find /home/$USER/Documents/github >> $DIR_LIST_FILE
find /home/$USER/Documents/work >> $DIR_LIST_FILE
find /home/$USER/Documents/tutorials >> $DIR_LIST_FILE
find /home/$USER/Documents/notes >> $DIR_LIST_FILE
find /home/$USER/Music/ >> $DIR_LIST_FILE
find /home/$USER/Videos/ >> $DIR_LIST_FILE
find /home/$USER/Pictures/ >> $DIR_LIST_FILE
