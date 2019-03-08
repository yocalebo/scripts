#!/usr/bin/env python3

import os
import sqlite3
from datetime import datetime
import pathlib
import glob
import subprocess
import syslog

VERSION_FILE = '/etc/version'
DB_FILE = '/data/freenas-v1.db'
DUMP_FILE = 'dump.sql'
DUMP_DIR = '/data/db_log/'
DIFF_FILE = 'changed.diff'

# TODO
# cleanup function

def check_version():
    if os.path.exists(VERSION_FILE):
        with open(VERSION_FILE, 'r') as f:
            # only return version string
            # leaving out the githash tag 
            version = f.read().strip().split(' ')
            return version[0]
    else:
        # if we can't find version file
        # then something is really bad so we exit
        syslog.syslog(syslog.LOG_ERR, 'FATAL: {} not found'.format(VERSION_FILE))
        exit(2)

def dump_db(abs_path):
    if os.path.exists(DB_FILE):
        con = sqlite3.connect(DB_FILE)
        file_name = os.path.join(abs_path, DUMP_FILE)
        with open(file_name, 'w') as f:
            for line in con.iterdump():
                f.write('{}\n' .format(line))
    else:
        # if we can't find db file
        # then something is really bad so we exit
        syslog.syslog(syslog.LOG_ERR, 'FATAL: {} not found'.format(DB_FILE))
        exit(2)

def mkdirs(cur_vers, cur_time):
    abs_path = os.path.join(DUMP_DIR, cur_vers, cur_time)
    pathlib.Path(abs_path).mkdir(parents=True, exist_ok=True)
    return abs_path

def latest_files(cur_vers):
    search_dir = os.path.join(DUMP_DIR, cur_vers)
    files = sorted(
            glob.iglob(search_dir + '/**/*.sql', recursive=True), reverse=True, key=os.path.getctime)
    # make sure we have 2 items
    # in the tuple to compare
    length = len(files) 
    if  length == 1: 
        exit(0)
    else:
        # file 0 is new dump file
        # file 1 is old dump file
        return files[0], files[1]

def diff(to_compare):
    new = to_compare[0]
    old = to_compare[1]

    diff = subprocess.run(
            ['diff', '-uw', old, new],
            stdout=subprocess.PIPE)

    dir_path = os.path.dirname(os.path.realpath(new))
    changed_file = os.path.join(dir_path, DIFF_FILE)
    if diff.stdout:
        with open(changed_file, 'w') as f:
            f.write('{}' .format(diff.stdout.decode('utf-8')))
    else:
        syslog.syslog(syslog.LOG_INFO, 'no changes detected')

def cleanup():
    pass

def main():
    cur_vers = check_version()
    cur_time = datetime.now().strftime("%m_%d_%Y_%I:%M%p")
    abs_path = mkdirs(cur_vers, cur_time)
    dump_db(abs_path)
    to_compare = latest_files(cur_vers)
    diff(to_compare)

if __name__ == '__main__':
    main()
