#!/bin/sh

# This script will recursively find all compressed files
# in the directory it is ran. If it finds any files,
# it will make a new directory using the same name as the tar file
# and then extract that tar file into the directory.

# Warning: this will keep going on and on until it can't find any compressed files. 

extract_all () {

        # Separate on newlines only
        IFS='
        '
        # Poor mans recursion
        found=0

        # Generate lits of files to extract
        filesfound="$(find . -name '*.tar' -o -name '*.tar.gz' -o -name '*.txz' -o -name '*.tgz' -type f)"


        if [ ! -z "$filesfound" ]; then
                while [ $found = 0 ]; do
                        for foundfiles in $filesfound; do
                                if [ -f "$foundfiles" ]; then
                                        echo "found $foundfiles"
                                        filename="${foundfiles#./}"
                                        dirname="${filename%.*}"
                                        echo "mkdir'ing $dirname"
                                        mkdir -p $dirname
                                        echo "extracting $filename to $dirname"
                                        # Let's not remove the tar file if we fail to extract
                                        if tar xf $filename -C $dirname; then
                                                echo "removing $filename"
                                                rm -f $filename
                                        else
                                                continue
                                        fi
                                else
                                        extract_all
                                fi
                        done
                done
        else
                exit 0
        fi
}

extract_all
