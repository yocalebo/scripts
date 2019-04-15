#!/bin/sh

##################################################################
# If trueNAS HA, then run on active controller and sync to peer. #
##################################################################

######################################################
# If this is TrueNAS single or FreeNAS, just run it. #
######################################################

KEYS_DIR="/usr/local/etc/ssh/"
KEYS_BCK="/usr/local/etc/ssh/backup/"

verify()
{
	if [ -d "${KEYS_DIR}" ]; then
		if output=$(mkdir -p ${KEYS_BCK}); then
			echo "SUCCESS: ${KEYS_BCK} created to store original keys"
		else
			echo "FATAL: unable to create ${KEYS_BCK}"
			echo "exiting"
			exit 1
		fi
	else
		echo "FATAL: ${KEYS_DIR} can't be read"
		echo "exiting"
		exit 1
	fi
}

backup()
{
	ORIG_KEYS="$(find ${KEYS_DIR} -maxdepth 1 -name 'ssh_host_*' -type f)"

	if [ ! -z "$ORIG_KEYS" ]; then
		for i in $ORIG_KEYS; do
			if output=$(cp -f $i $KEYS_BCK); then
				echo "SUCCESS: backed up $i to $KEYS_BCK"
			else
				echo "FATAL: failed to backup $i to $KEYS_BCK"
				exit 1
			fi
		done
	else
		echo "WARN: unable to find host keys in $KEYS_DIR"
		echo "WARN: proceeding as usual"
	fi
}

remove_keys()
{
	if output=$(rm -f ${KEYS_DIR}/ssh_host_*); then
		echo "SUCCESS: removed original keys"
	else
		echo "FATAL: unable to remove original keys"
		exit 1
	fi
}

restart_ssh()
{
	if output=$(/usr/sbin/service openssh onerestart); then
		echo "SUCCESS: new host keys generated"
	else
		echo "FATAL: unable to generate new host keys"
	fi
}

copy_keys_to_db()
{
	if output=$(/bin/sh /etc/ix.rc.d/ix_sshd_save_keys start); then
		echo "SUCCESS: new host keys written to database"
	else
		echo "FATAL: unable to write new host keys to database"
		echo "FATAL: the new keys will not be persistent across reboots"
	fi
}

verify
backup
remove_keys
restart_ssh
copy_keys_to_db
