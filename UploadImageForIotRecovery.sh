#!/bin/bash

## UploadImageForIotRecovery.sh v1.0
## Copyright 2018, ClearCenter
## Script licensed under GNU AFFERO GENERAL PUBLIC LICENSE v3
## https://www.gnu.org/licenses/agpl-3.0.en.html
## DESCRIPTION:
## This script conveys locally accepted SSH key to a target destination server.
## VERSION:
## This version is known to work with Ubuntu Core installations.

## TUNABLE VARIABLES ##
#  The username on the target device that you will use to conduct this process. This user must 
#  have a private key which it can use to scp the files off of the source server. This user must
#  also be able to 'su' as root without a password.
defsshuser=admin
#  The password of the user on the target device
defsshpasswd=admin
#  The SSH port of the server that contains the recovery files
defsshsourceport=4321
#  The SSH port of the target device
defsshdestinationport=22
#  The non-privileged account on the source server that has the recovery image files. This user MUST
#  trust the SSH key of the account on the target device for ssh access.
defsshfileuser=files
#  The location of the images directory...NOT THE IMAGE
defimagessourcedir=/home/files/assets/images
#  The name of the image as defined by the directory. This folder must have the efi directory of the 
#  recovery image
defimagename=300x-recovery

## LOCATE PATHS AND PROGRAMS USED ##
# Command Variables for Crontab support
cmd_which=/usr/bin/which
cmd_echo=/usr/bin/echo
cmd_sed=/usr/bin/sed
cmd_awk=/usr/bin/awk
cmd_cat=/usr/bin/cat

#  Install 'sed' if missing or path is wrong
$cmd_which sed > /dev/null 2>&1 && true || sudo yum -y install sed > /dev/null 2>&1
$cmd_which sed > /dev/null 2>&1 && true || $cmd_echo Failed to find or install \"sed\" program. Please install and try again.
#  Install 'gawk' if missing or path is wrong
$cmd_which awk > /dev/null 2>&1 && true || sudo yum -y gawk expect > /dev/null 2>&1
$cmd_which awk > /dev/null 2>&1 && true || $cmd_echo Failed to find or install \"awk\" program. Please install gawk and try again.

## FUNCTIONS ##
#Help Function
help_text () {
    $cmd_echo "UploadImageForIotRecovery.sh [ File Source IPaddress|Hostname ] [ Target Machine to be Imaged IPaddress|Hostname ] (OPTIONAL: [ username ] [ password | \"Pass Word\" ] [ File Source SSH Port ] [ Target Machine to be Imaged SSH Port ] [ File Source username ])"
}

## VARIABLES ##
#  Input Validation
if [ -z ${1+x} ]; then help_text && exit 1; else sshsourcehost=${1}; fi
if [ -z ${2+x} ]; then help_text && exit 1; else sshdestinationhost=${2}; fi
#  Optional Parameters and Validation
if [ -z ${3+x} ]; then sshuser=${defsshuser}; else sshuser=${3}; fi
if [ -z ${4+x} ]; then sshpasswd=${defsshpasswd}; else sshpasswd=${4}; fi
if [ -z ${5+x} ]; then sshsourceport=${defsshsourceport}; else sshsourceport=${5}; fi
if [ -z ${6+x} ]; then sshdestinationport=${defsshdestinationport}; else sshdestinationport=${6}; fi
if [ -z ${7+x} ]; then sshfileuser=${defsshfileuser}; else sshfileuser=${7}; fi
if [ -z ${8+x} ]; then imagessourcedir=${defimagessourcedir}; else imagessourcedir=${8}; fi
if [ -z ${9+x} ]; then imagename=${defimagename}; else imagename=${9}; fi

if [ ${sshuser} = "root" ]; then homedir=""; else homedir="home"; fi

## VARIABLE VALIDATION ##
#  Validate Source User
echo Validating source user
if [ ! -d ${imagessourcedir} ]; then exit 1
#  Validate source directory
echo validating source directory
if [ ! -d ${imagessourcedir} ]; then exit 1
#  Validate Source Image
echo validating source image
if [ ! -d ${imagessourcedir}/${imagename}/efi ]; then exit 1

## PREPARATION ##
ssh ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} if [ -d /${homedir}/${sshuser}/${imagename} ]; then rm -rf /${homedir}/${sshuser}/${imagename}/*; else mkdir -p /${homedir}/${sshuser}/${imagename}; fi || echo failed to ssh
ssh ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} <<'ENDSSH'
  if [[ $HOME ]]; then hostname; fi
ENDSSH
if ssh ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} 

## VALIDATION ##

## MAIN PROGRAM ##
#  Run Program

# Land the recovery image in /${homedir}/${sshuser} need routine to clean up if already exists
[root@edgeserver1 ~]# ssh ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} mkdir /${homedir}/${sshuser}/${imagename}
[root@edgeserver1 ~]# ssh ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} ls -la /${homedir}/${sshuser}/${imagename}
total 8
drwxrwxr-x 2 ${sshuser} ${sshuser} 4096 Apr 15 16:36 .
drwxr-xr-x 7 ${sshuser} ${sshuser} 4096 Apr 15 16:36 ..

# From the destination server grab the files. Should validate after copy that efi folder exists. Also, this requires trust between from the files user to the private key on the target server.
[root@edgeserver1 ~]# ssh ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} scp -r -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P ${sshsourceport} files@${sshsourcehost}:${imagessourcedir}/${imagename}/* /${homedir}/${sshuser}/${imagename}/
Warning: Permanently added '[x.x.x.x]:xx' (ECDSA) to the list of known hosts.

# Run these after the data is on the destination server in the /${homedir}/${sshuser} dir
[root@edgeserver1 ~]# ssh ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} mkdir -p /mnt/1
[root@edgeserver1 ~]# ssh ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} sudo mount /dev/mmcblk0p1 /mnt/1
# Validate the recovery_partition through the mount and the existance of an efi folder. If efi doesn't exist...it is not a recovery part
[root@edgeserver1 ~]# ssh ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} sudo ls /mnt/1

# Destroying the data on the recovery partition should happen just before the copy of the data from /${homedir}/${sshuser}
[root@edgeserver1 ~]# ssh ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} sudo rm -rf /mnt/1/*
[root@edgeserver1 ~]# ssh ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} sudo ls /mnt/1

# Copy the image to the mount location
[root@edgeserver1 ~]# ssh ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} sudo cp -a /${homedir}/${sshuser}/${imagename}/* /mnt/1/

## CLEANUP ##

