# Lazy Admin

> Converted from cybersecurity DOCX notes into a structured markdown outline and study reference.

## Enumeration

- command: sudo Nmap -A 10.10.135.70

- port 22 is the only one that showed up

- command: Nmap -Pn -p- 10.10.135.70

- checking for unseen attack surface

- on ports 80 and 22 are identified…

- command: dirb http://10.10.135.70 /usr/share/wordlists/dirb/common.txt

- try to enumerate some directories

- found: "content" directory, but was only the landing page for the content management system

- found "content/as" is the administrative portal

- found "content/_themes" full of php files

- found "content/inc/" which has all kinds of files, including a sql backup file

## Foothold

- command: ssh admin@10.10.135.70

- could connect

- admin, password, Password, password123, Password123 all failed

- command: hydra -l admin -P /usr/share/wordlists/rockyou.txt ssh

- try to break into ssh

## Exploit The SQL Backup File

- download the sql file

- open in mousepad

- found a password and used crackstation

- username: manager

- password: Password123

- able to login

- the software is "Sweetrice" version 1.5.1

- lookup the software on exploitdb.com

- found and "arbitrary file upload" vulnerability

## Exploit

- pick webshell from /usr/share/webshells/php

- chose reverse shell

- changed the IP and port in the webshell

- command: "nc -lvnp 8888" to open the listener

- command: "python <exploitname>.py"

- asked for the username, password, and shell file name

- the target url had to be "10.10.177.235/content/" because the python code automatically appended the "as"

- automatically uploaded the reverse shell and gave a file path which could exploit the vile

- the link didn't work. Suspect the .php extension is blocked.

- tried a php5 extension but didn't work

- phtml extension worked!

- Navigate into home > itguy and found user.txt

## Privilege Escalation

- command: "sudo -l"

- there is a perl file in the results

- command: "cat /home/itguy/backup.pl"
---two lines in the file

- line 1: #!/usr/bin/perl

- line 2: "system("sh", "/etc/copy.sh");

- command "ls -alh /etc/copy.sh"

- owner is root

- command: "cat /etc/copy.sh"
---there is an IP address and a port in the file

- start netcat listener on the port in the file (5554)

- change the IP address to my IP by using "echo" to rewrite the entire line substituting attacker IP

- navigate to the itguy directory and run thecommand to run the perl script: "sudo /usr/bin/perl /home/itguy/backup.pl"

- get the reverse shell

- verify with "whoami"
