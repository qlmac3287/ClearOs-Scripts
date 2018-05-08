#!/bin/bash

## AddFilesUserAccessKey.sh v1.0
## Copyright 2018, ClearCenter
## Script licensed under GNU AFFERO GENERAL PUBLIC LICENSE v3
## https://www.gnu.org/licenses/agpl-3.0.en.html
## DESCRIPTION:
## This script conveys locally accepted SSH key to a target destination server.
## VERSION:
## This version is known to work with Ubuntu Core installations.

## LOCATE PATHS AND PROGRAMS USED ##
# Command Variables for Crontab support
cmd_which=/usr/bin/which
cmd_sshkeygen=/usr/bin/ssh-keygen
cmd_scp=/usr/bin/scp
cmd_echo=/usr/bin/echo

## FUNCTIONS ##
#Help Function
help_text () {
    $cmd_echo "AddFilesUserAccessKey.sh [ IPaddress | Hostname ] (OPTIONAL: [ username ] [ port ])"
}

## VARIABLES ##
#  Input Validation
if [ -z ${1+x} ]; then help_text && exit 1; else sshhost=${1}; fi
#  Optional Parameters and Validation
if [ -z ${2+x} ]; then sshuser=admin; else sshuser=${2}; fi
if [ -z ${3+x} ]; then sshport=22; else sshport=${3}; fi

## VALIDATION ##

## MAIN PROGRAM ##
#  Run Program
ls /home/files/.ssh/id_rsa || sudo -i -u files printf '\n' | $cmd_sshkeygen -f /home/files/.ssh/id_rsa -N ''
$cmd_scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P ${sshport} /home/files/.ssh/id_rsa* ${sshuser}@${sshhost}:~/.ssh/ || exit 1
exit 0
