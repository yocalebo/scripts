#!/usr/sbin/dtrace -s

/* ::nfsrv_checkuidgid:entry
{
	this->va_uid = args[1]->na_vattr.va_uid;
	print(*(args[0]));
	printf("uid %d", this->va_uid);
}
::nfsrv_checkuidgid:return
{ 
	printf("XXXX %d", *((struct nfsvattr *)self->na)->na_uid);
}
*/

::nfsv4_strtouid:entry
{
	self->nd = (struct nfsrv_descript *)arg0;
	self->str = arg1;
	self->uidp = arg3;
	self->len = arg2;
 	printf("len=%d, str=%s\n", arg2, stringof(arg1));
}


::nfsv4_strtouid:return
{
	printf("uidp=%d ret=%d\n", *((int *)self->uidp), arg1);
}


::nfsv4_strtogid:entry
{
	self->nd = (struct nfsrv_descript *)arg0;
	self->str = arg1;
	self->gidp = arg3;
	self->len = arg2;
	printf("len=%d, str=%s\n", arg2, stringof(arg1));
}

::nfsv4_strtogid:return
{
	printf("gidp=%d ret=%d\n", *((int *)self->gidp), arg1)
}

/* ::nfssvc_idname:entry
{
	self->nidp = (struct nfsd_idargs *)arg0;

	print(*self->nidp);

print(*(args[0]));

	printf("nnid_name=%s nid_namelen=%d\n", copyinstr((uintptr_t)self->nidp->nid_name), self->nidp->nid_namelen);
}
*/
