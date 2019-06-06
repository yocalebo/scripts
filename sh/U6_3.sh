#!/bin/sh

# This script is a quick way to patch the known issues
# related to the 11.1-U6.3 TrueNAS release

# Patch ix-crontab
# Fixes cloud sync tasks failing to run automatically

verify()
{
	if [ -r "/etc/version" ]; then
		version=$(grep -r 'TrueNAS-11.1-U6.3' /etc/version 2> /dev/null)

		if [ "$version" = "" ]; then
			echo "wrong version of TrueNAS"
			echo "expecting TrueNAS-11.1-U6.3"
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
	if [ -r "/conf/base/etc/ix.rc.d/ix-crontab" ]; then
		echo "Backing up original file"
		cp /conf/base/etc/ix.rc.d/ix-crontab /conf/base/etc/ix.rc.d/ix-crontab.orig
	else
		echo "file ix-crontab not found"
		echo "exiting"
		exit 1 
	fi
}

patch_crontab()
{
	file_to_patch="/conf/base/etc/ix.rc.d/ix-crontab"
	
	echo "applying patch"
	sed -i -e 's/cloudsync.sync/backup.sync/g' $file_to_patch
	echo "restarting cron task"
	cp $file_to_patch /etc/ix.rc.d/
	service ix-crontab start
	echo "patch applied successfully"
	exit 0
}

verify
backup
patch_crontab
