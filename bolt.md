# Bolt

This room is designed for users to get familiar with the Bolt CMS and how it can be exploited using Authenticated Remote Code Execution  

## Enumeration

### Network Enumeration

`:> nmap -Pn <attacker ip>`  

```md
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
8000/tcp open  http-alt

```

`:> nmap -Pn -sV -p 8000 <attacker ip>`  

```md
PORT     STATE SERVICE VERSION
8000/tcp open  http    (PHP 7.2.32-1)
```

`:> gobuster dir -u http://<target>:<port> -w /usr/share/wordlists/dirb/big.txt`  

```md
Starting gobuster in directory enumeration mode
===============================================================
/.htaccess            (Status: 200) [Size: 2956]
/async                (Status: 401) [Size: 2188]
/entries              (Status: 200) [Size: 6661]
/pages                (Status: 200) [Size: 4991]
/search               (Status: 200) [Size: 5550]
Progress: 20469 / 20470 (100.00%)
```

### Web Page Review  

Username and password leaked  

Nothing relevant in source code  

### Logged in

![Logged In](/assets/bolt-101.png)  

## Initial Access

[Exploit-db exploit code](https://www.exploit-db.com/exploits/48296)  

Metasploit Module:  

![msfconsole exploit](/assets/bolt-102.png)  

`:> cat /home/flag.txt`  