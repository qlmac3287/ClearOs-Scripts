#!/bin/bash

## DellInstallDccViaSnap.sh v1.0
## Copyright 2018, ClearCenter
## Script licensed under GNU AFFERO GENERAL PUBLIC LICENSE v3
## https://www.gnu.org/licenses/agpl-3.0.en.html
## DESCRIPTION:
## This script installs dcc tools
## VERSION:
## This version is known to work with Ubuntu Core installations.

## LOCATE PATHS AND PROGRAMS USED ##
# Command Variables for Crontab support
cmd_which=/usr/bin/which
cmd_snap=/usr/bin/snap
cmd_egrep=/bin/egrep
cmd_echo=/bin/echo

#  Install 'dcc' if missing or path is wrong
${cmd_snap} list | ${cmd_egrep} "^dcc\s+[0-9\.]+\s+[0-9\.]+\s+dell-inc\s+-$" && ${cmd_echo} Package already installed || sudo ${cmd_snap} install dcc
${cmd_snap} list | ${cmd_egrep} "^dcc\s+[0-9\.]+\s+[0-9\.]+\s+dell-inc\s+-$" && ${cmd_echo} Script succeeded || ${cmd_echo} Installation failed
