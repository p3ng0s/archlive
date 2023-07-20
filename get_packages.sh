#!/bin/bash
# get_packages.sh
# Created on: Thu 22 Sep 2022 11:44:59 PM BST
#
#  ____   __  ____  __
# (  _ \ /. |(  _ \/  )
#  )___/(_  _))___/ )(
# (__)    (_)(__)  (__)
#
# Description:
#  A script to get all of my installed packages localy


ALL_EXISTING_PACKAGES=/tmp/all_packages
INSTALLED_PACKAGES=/tmp/installed_packages
NOT_IN_REPO_PACKAGES=/tmp/not_in_main_repo
PACKAGE_FILE=./packages_to_install

pacman -Slq | sort -u > $ALL_EXISTING_PACKAGES
pacman -Q | cut -d' ' -f1 | sort -u > $INSTALLED_PACKAGES

comm -23 $INSTALLED_PACKAGES $ALL_EXISTING_PACKAGES > $NOT_IN_REPO_PACKAGES

cat $NOT_IN_REPO_PACKAGES | xargs -l -I'{}' sed -i /{}/d $INSTALLED_PACKAGES

cp -r $INSTALLED_PACKAGES $PACKAGE_FILE
