#!/bin/bash

## SeedSshKey.sh v1.0
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
cmd_expect=/usr/bin/expect
cmd_echo=/usr/bin/echo
cmd_sed=/usr/bin/sed
cmd_awk=/usr/bin/awk
cmd_cat=/usr/bin/cat

#  Install 'expect' if missing or path is wrong
$cmd_which expect > /dev/null 2>&1 && true || sudo yum -y install expect > /dev/null 2>&1
$cmd_which expect > /dev/null 2>&1 && true || $cmd_echo Failed to find or install \"expect\" program. Please install and try again.
#  Install 'sed' if missing or path is wrong
$cmd_which sed > /dev/null 2>&1 && true || sudo yum -y install sed > /dev/null 2>&1
$cmd_which sed > /dev/null 2>&1 && true || $cmd_echo Failed to find or install \"sed\" program. Please install and try again.
#  Install 'gawk' if missing or path is wrong
$cmd_which awk > /dev/null 2>&1 && true || sudo yum -y gawk expect > /dev/null 2>&1
$cmd_which awk > /dev/null 2>&1 && true || $cmd_echo Failed to find or install \"awk\" program. Please install gawk and try again.

## FUNCTIONS ##
#Help Function
help_text () {
    $cmd_echo "SeedSshKey.sh [ KeyName | \"KeyName\" ] [ IPaddress | Hostname ] (OPTIONAL: [ username ] [ password | \"Pass Word\" ] [ port ]\")"
}
available_keys () {
    $cmd_echo
    $cmd_echo "Public key name \"${publickeytitle}\" is not found in ${keyfile}"
    $cmd_echo
    $cmd_echo "--AVAILABLE KEYS--"
    $cmd_cat ${keyfile} | ${cmd_awk} '{ print substr($0, index($0,$3)) }' | ${cmd_sed} 's/^$/<key missing label>/g'
    $cmd_echo
}

## VARIABLES ##
#  Default Variables
keyfile="$HOME/.ssh/authorized_keys"
#  Input Validation
if [ -z ${1+x} ]; then help_text && exit 1; else publickeytitle=${1}; fi
if [ -z ${2+x} ]; then help_text && exit 1; else sshhost=${2}; fi
#  Optional Parameters and Validation
if [ -z ${3+x} ]; then sshuser=root; else sshuser=${3}; fi
if [ -z ${4+x} ]; then sshpasswd="Clear05!"; else sshpasswd=${4}; fi
if [ -z ${5+x} ]; then sshport=22; else sshport=${5}; fi

## VALIDATION ##
#  Target File Validation
if [ ! -f ${keyfile} ]; then $cmd_echo "Authorized key file does not exist: ${keyfile}" && exit 1; fi
#  Public Key Validation
publickey=$(grep ${publickeytitle}$ $HOME/.ssh/authorized_keys)
#if [ -z ${publickey} ]; then $cmd_echo "Public key name \"${publickeytitle}\" is not found in ${keyfile}" && exit 1; fi
if [ -z "${publickey}" ]; then available_keys && exit 1; fi

## EXPECT EXECUTION ##
#  Execute on remote server non-privileged user
$cmd_expect <<EOD
spawn ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${sshuser}@${sshhost}
expect "password: "
send "${sshpasswd}\n" 
expect "# " { send "if bash -c \'\[\[ -d ~/.ssh \]\]\'; then mkdir -p ~/.ssh && chmod 0700 ~/.ssh; fi\r" }
expect "# " { send "if bash -c \'\[\[ -f ~/.ssh/authorized_keys \]\]\'; then touch ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys; fi\r" }
expect "# " { send "grep ${publickeytitle} ~/.ssh/authorized_keys && echo Key already exists || echo ${publickey} >> ~/.ssh/authorized_keys\r" }
expect "# " { send "exit\r" }
EOD
$cmd_echo
exit 0

