#!/bin/bash


################ Seed SSH key

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
    $cmd_echo "SeedSshKey.sh [ KeyName | \"Key Name\" ] [ IPaddress | Hostname ] (OPTIONAL: [ username ] [ password | \"Pass Word\" ] [ port ]\")"
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
if [ -z ${3+x} ]; then sshuser=admin; else sshuser=${3}; fi
if [ -z ${4+x} ]; then sshpasswd=admin; else sshpasswd=${4}; fi
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
expect "$ " { send "if bash -c \'\[\[ -d ~/.ssh \]\]\'; then mkdir -p ~/.ssh && chmod 0700 ~/.ssh; fi\r" }
expect "$ " { send "if bash -c \'\[\[ -f ~/.ssh/authorized_keys \]\]\'; then touch ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys; fi\r" }
expect "$ " { send "grep ${publickeytitle} ~/.ssh/authorized_keys && echo Key already exists || echo ${publickey} >> ~/.ssh/authorized_keys\r" }
expect "$ " { send "exit\r" }
EOD
$cmd_echo
exit 0

################ Validate SecureBoot is off

################ Send files user key

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
cmd_ssh-keygen=/usr/bin/ssh-keygen
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
ls /home/files/.ssh/id_rsa || sudo -i -u files printf '\n' | $cmd_ssh-keygen -f /home/files/.ssh/id_rsa -N ''
$cmd_scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P ${sshport} /home/files/.ssh/id_rsa* ${sshuser}@${sshhost}:~/.ssh/ || exit 1
exit 0

################ Copy Image to recovery partition

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
#  The partition name of the recovery partition
defrecoverypartition=mmcblk0p1

## LOCATE PATHS AND PROGRAMS USED ##
# Command Variables for Crontab support
cmd_which=/usr/bin/which
cmd_echo=/usr/bin/echo
cmd_sed=/usr/bin/sed
cmd_awk=/usr/bin/awk
cmd_cat=/usr/bin/cat
#  Install 'sed' if missing or path is wrong
#$cmd_which sed > /dev/null 2>&1 && true || sudo yum -y install sed > /dev/null 2>&1
#$cmd_which sed > /dev/null 2>&1 && true || $cmd_echo Failed to find or install \"sed\" program. Please install and try again.
#  Install 'gawk' if missing or path is wrong
#$cmd_which awk > /dev/null 2>&1 && true || sudo yum -y gawk expect > /dev/null 2>&1
#$cmd_which awk > /dev/null 2>&1 && true || $cmd_echo Failed to find or install \"awk\" program. Please install gawk and try again.
if ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -oBatchMode=yes ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} ls /${homedir}/${sshuser}/${imagename}/efi; then ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -oBatchMode=yes ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} rm -rf /${homedir}/${sshuser}/${imagename}/*; echo directory exists and was purged; else ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -oBatchMode=yes ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} mkdir -p /${homedir}/${sshuser}/${imagename}; echo directory created; fi

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
if [ -z ${10+x} ]; then recoverypartition=${defrecoverypartition}; else recoverypartition=${10}; fi
if [ ${sshuser} = "root" ]; then homedir=""; else homedir="home"; fi

## VARIABLE VALIDATION ##
#  Validate Source User
echo Validating source user
if [ ! -d ${imagessourcedir} ]; then echo Source directory does not exist; exit 1; fi
#  Validate source directory
echo validating source directory
if [ ! -d ${imagessourcedir} ]; then echo Source directory does not exist; exit 1; fi
#  Validate Source Image
echo validating source image
if [ ! -d ${imagessourcedir}/${imagename}/efi ]; then echo Source image does not exist; exit 1; fi

## PREPARATION ##
#  Example
#ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -oBatchMode=yes -p ${sshdestinationport} ${sshuser}@${sshdestinationhost} /bin/bash << EOF
#	echo \`hostname\` not `hostname` on $sshsourcehost
#EOF

#if ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -oBatchMode=yes ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} ls /${homedir}/${sshuser}/${imagename}/efi; then 
#    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -oBatchMode=yes ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} rm -rf /${homedir}/${sshuser}/${imagename}/*
#    echo directory exists and was purged
#else
#    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -oBatchMode=yes ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} mkdir -p /${homedir}/${sshuser}/${imagename}
#    echo directory created
#fi

#  Setup and purge target imaging directory
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -oBatchMode=yes -p ${sshdestinationport} ${sshuser}@${sshdestinationhost} /bin/bash << EOF
	if [ ! -d /${homedir}/${sshuser}/${imagename} ]; then mkdir -p /${homedir}/${sshuser}/${imagename}; fi
	if [ -d /${homedir}/${sshuser}/${imagename} ]; then 
		[ "\$(ls -A /${homedir}/${sshuser}/${imagename})" ] && rm -rf /${homedir}/${sshuser}/${imagename}/* || echo "Directory is empty and ready for files"
	fi
EOF

## MAIN PROGRAM ##
#  Run Program

# From the destination server grab the files. Should validate after copy that efi folder exists. Also, this requires trust between from the files user to the private key on the target server.
ssh ${sshuser}@${sshdestinationhost} -p ${sshdestinationport} scp -r -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P ${sshsourceport} ${sshfileuser}@${sshsourcehost}:${imagessourcedir}/${imagename}/* /${homedir}/${sshuser}/${imagename}/
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -oBatchMode=yes -p ${sshdestinationport} ${sshuser}@${sshdestinationhost} /bin/bash << EOF
	if [ ! -d /${homedir}/${sshuser}/${imagename}/efi ]; then echo Image directory is invalid; exit 1; fi
EOF


# Run these after the data is on the destination server in the /${homedir}/${sshuser} dir
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -oBatchMode=yes -p ${sshdestinationport} ${sshuser}@${sshdestinationhost} /bin/bash << EOF
	sudo mkdir -p /mnt/${imagename} && echo mkdir /mnt/${imagename} suceeded
	sudo mount | grep ${imagename} && true || sudo mount /dev/${recoverypartition} /mnt/${imagename} 
	sudo mount | grep ${imagename} && echo Device mounted || exit 1 
	[ "\$(ls -A /mnt/${imagename})" ] && sudo rm -rf /mnt/${imagename}/* || echo Parition empty as expected or command failed.
	[ "\$(ls -A /mnt/${imagename})" ] && exit 1 || echo Partition ready for transfer.
	sudo cp -a /${homedir}/${sshuser}/${imagename}/* /mnt/${imagename}/ && echo Please Note - Ignore preservation of permissions issues. These issue are expected on FAT32 UEFI volumes.
	[ "\$(ls -A /mnt/${imagename}/efi)" ] && echo Copy completed || exit 1
	sudo umount /mnt/${imagename} && echo Recovery Partition Unmounted || exit 1
	sudo rmdir /mnt/${imagename} && echo Cleanup temporary mount directory concluded || exit 1
EOF
	
exit 0

################ Preflight, efibootmgr, reboot
