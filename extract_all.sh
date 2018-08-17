#!/bin/sh

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
					tar xzf $filename -C $dirname
					echo "removing $filename"
					rm -rf $filename
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
