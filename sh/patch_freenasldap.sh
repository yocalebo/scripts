#!/bin/sh

# This file is used to patch a regression with local users
# in version 11.1-U7 of freeNAS.

# Note, the diff file has to be generated manually
# from this commit: https://github.com/freenas/freenas/pull/2637/files

DIFF_FILE="/root/freenasldap.diff"
ORIG_FILE="/usr/local/www/freenasUI/common/freenasldap.py"
BACK_FILE="/usr/local/www/freenasUI/common/freenasldap.py.BACK"

verify()
{
	if [ -r "/etc/version" ]; then
		version=$(grep -r 'TrueNAS-11.1-U7' /etc/version 2> /dev/null)

		if [ "$version" = "" ]; then
			echo "wrong version of TrueNAS"
			echo "expecting TrueNAS-11.1-U7"
			echo "exiting"
			exit 1 
		fi

	else
		echo "file /etc/version not found"
		echo "exiting"
		exit 1 
	fi
}

backup()
{
	if [ -r "${ORIG_FILE}" ]; then
		echo "backing up original file"
		if output=$(cp ${ORIG_FILE} ${BACK_FILE} > /dev/null 2>&1); then
			echo "backup succeeded"
		else
			echo "backup failed"
			echo "exiting"
			exit 1 
		fi
	else
		echo "${ORIG_FILE} not found"
		echo "exiting"
		exit 1 
	fi
}

patch()
{
	if [ -r "${DIFF_FILE}" ]; then
		echo "applying patch"
		if output=$(/usr/bin/patch ${ORIG_FILE} ${DIFF_FILE} > /dev/null 2>&1); then
			echo "patch succeeded"
		else
			echo "patch failed"
			echo "restoring original file"
			if output=$(cp ${BACK_FILE} ${ORIG_FILE} > /dev/null 2>&1); then
				echo "restored original file"
				echo "exiting"
				exit 1 
			else
				echo "restoring original file failed"
				echo "please manually intervene"
				exit 1 
			fi
		fi
	else
		echo "can't find ${DIFF_FILE}"
		echo "exiting"
		exit 1 
	fi
}

restart()
{
	echo "restarting necessary services"
	if output1=$(service middlewared onerestart > /dev/null 2>&1); then
		echo "restarting middlewared succeeded"
	else
		echo "restarting middlewared failed"
		exit 1 
	fi

	if output2=$(service django onerestart > /dev/null 2>&1); then
		echo "restarting django succeeded"
	else
		echo "restarting django failed"
		exit 1 
	fi

	if output3=$(service nginx onerestart > /dev/null 2>&1); then
		echo "restarting nginx succeeded"
	else
		echo "restarting nginx failed"
		exit 1 
	fi
}

verify
backup
patch
restart
