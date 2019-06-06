#!/usr/sbin/dtrace -qs

# simple dtrace script to print the size of a struct/union
# this particular struct is the segment size of a ZFS trim
# specifically, I used this to see how much RAM it would take
# by increasing the vfs.zfs.vdev.trim_max_pending parameter

BEGIN
{
	size = sizeof (struct trim_seg);
	printf("size = %u", size);
	exit(0)
}
