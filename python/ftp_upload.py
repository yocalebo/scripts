#!/usr/bin/env python3

# Quick and dirty python script
# to upload files to an ftp server
from ftplib import FTP
import sys

USERNAME = 'change_me'
PASSWORD = 'change_me'
FTP_SITE = 'change_me'


def usage():
    print("usage: ./ftp_upload.py [file1 file2..]")

if len(sys.argv) < 2:
    usage()
    sys.exit(2)

try:
    ftp_conn = FTP(host=FTP_SITE, user=USERNAME, passwd=PASSWORD, timeout=5)
except:
    sys.stderr.write("error connecting to server: '{0}'\n" % (FTP_SITE))
    ftp_conn.close()
    sys.exit(2)

for files in sys.argv[1:]:
    with open(files, 'rb') as f:
        try:
            print("uploading '{0}' to '{1}'" % (files, FTP_SITE))
            ftp_conn.storbinary("STOR '{0}'".format(files), f)
        except:
            sys.stderr.write("uploading failed for '{0}' to '{1}'\n" % (files, FTP_SITE))
            sys.stderr.write("quitting\n")
            ftp_conn.close()
            sys.exit(2)
