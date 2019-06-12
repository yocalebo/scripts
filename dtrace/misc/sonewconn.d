#!/usr/sbin/dtrace -s

fbt::sonewconn:return
'/args[1] == NULL/
{ 
	print("sonewconn returned NULL\n\n"); 
	printf("user stack %s (%d)\n\n", execname, pid);
	ustack();
	print("\n\nKernel stack");
	stack();
}'
