#!/bin/sh

# This script will recursively find all compressed files
# in the directory it is ran. If it finds any files,
# it will make a new directory using the same name as the tar file
# and then extract that tar file into the directory.

# Warning: this will keep going on and on until it can't find any compressed files. 

do_stuff () {

	found=0
	curr_dir=`pwd`
	
	findfiles=$(find $curr_dir -name '*.tar' -o -name '*.tar.gz' -o -name '*.tgz' -o -name '*.txz' -type f)
	
	if [ ! -z "$findfiles" ]; then
		while [ $found == 0 ]; do
			for filesfound in $findfiles; do
				if [ -f "$filesfound" ]; then
					echo "found $filesfound"
					filename="${filesfound#./}"
					dirname="${filename%.*}"
					echo "mkdir'ing $dirname"
					mkdir -p $dirname
					echo "extracting $filename to $dirname"
					# Let's not remove the tar file if we fail to extract
					if tar xf $filename -C $dirname; then
						echo "removing $filename"
						rm -rf $filename
					else
						continue
					fi
				else
					do_stuff
				fi
			done
		done
	else
		exit 0
	fi
}

do_stuff
