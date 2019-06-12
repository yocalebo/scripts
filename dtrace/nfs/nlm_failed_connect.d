#!/usr/sbin/dtrace -s


/* If you receive error messages similar to the message below,
 * this usually means an NFS client is failing to connect
 * for some reason or the other.
 *
 * To know what IP address is failing to connect and cause
 * these error messages, run this dtrace script.
 *
 * NLM: failed to contact remote rpcbind, stat = 5, port = 28416 
 *
 * /

fbt::nlm_get_rpc:entry
{
    this->hints = (struct sockaddr_in *)arg0;
    printf("family=%x addr=%d.%d.%d.%d",
        this->hints->sin_family,
        this->hints->sin_addr.s_addr & 0xFF,
        (this->hints->sin_addr.s_addr >> 8) & 0xFF,
        (this->hints->sin_addr.s_addr >> 16) & 0xFF,
        (this->hints->sin_addr.s_addr >> 24) & 0xFF);
}
