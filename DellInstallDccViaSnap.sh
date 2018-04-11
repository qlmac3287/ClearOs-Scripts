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

#  Install 'dcc' if missing or path is wrong
