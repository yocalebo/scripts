#!/usr/sbin/dtrace -qs

/* simple dtrace script to track activity
 * related to the open syscall on freeBSD
 */


#pragma D option switchrate=10Hz

BEGIN
{
	printf("UID\tPID\tCOMMAND\t\tPATH\n");
}
syscall::open:entry
{
	/* get pathname on entry */
	self->pathp = arg0;
}

syscall::open:return
{
	printf("%d\t%d\t%s\t%s\n", uid, pid, execname, copyinstr(self->pathp));
}

END
{
	/* clean up after ourselves */
	self->pathp = 0;
	exit(0)
}
