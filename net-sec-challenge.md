# Net Sec Challenge

## Highest Open Port Below 10,000

### Question

What is the highest port number being open less than `10,000`?

### Notes

- Initial scan suggested ports up to `8080`:

```bash
nmap <ip> -v
```

- Additional scans above `8080` did not reveal a higher confirmed open port:

```bash
nmap <ip> -p 8081-10000 -v -sT
nmap <ip> -p 8081-10000 -sN
nmap <ip> -p 8081-10000 -sF -v
nmap <ip> -p 8081-10000 -sU -v
```

- Observations:
  - TCP connect scan indicated ports `8081-10000` were closed.
  - FIN scan showed some `open|filtered` results, but nothing confirmed.
  - UDP scan showed ports closed.

### Answer

- Attempted answer: `8080`

## Open Port Above 10,000

### Question

There is an open port outside the common 1000 ports; it is above `10,000`. What is it?

### Notes

- Banner scan revealed an SSH flag on port `22`:

```bash
nmap <ip> -sT --script=banner
```

- Flag observed on SSH:

```text
THM{946219583339}
```

- Scan from port `10000` found the nonstandard service:

```bash
nmap <ip> -sT -p 10000- -r
```

- Deeper service scan:

```bash
nmap <ip> -sC -sT -r -p- -v
```

### Answer

- Open port: `10021`

## HTTP Server Header Flag

### Question

What is the flag hidden in the HTTP server header?

### Notes

- Basic request did not show the flag:

```bash
curl http://<ip>:<http-port>
```

- Header retrieval showed the flag:

```bash
curl http://10.10.233.168:80 -I
```

### Operational Note

- The `-I` option retrieves only the response headers.
- This is useful when a challenge or investigation hints that metadata may contain evidence.

## Nonstandard FTP Version

### Question

We have an FTP server listening on a nonstandard port. What is the version of the FTP server?

### Command

```bash
nmap 10.10.233.168 -p 10021 -sV
```

### Answer

- FTP server version: `vsftpd 3.0.3`

## FTP Account Flag

### Question

We learned two usernames using social engineering: `eddie` and `quinn`. What is the flag hidden in one of these two account files and accessible via FTP?

### Notes

- Create a username list:

```bash
touch ftp.txt
```

- Add usernames:
  - `eddie`
  - `quinn`

- Brute force FTP credentials:

```bash
hydra ftp <ip> -s <port> -L usernames.txt -P passwordfile.txt
```

- Credentials found:
  - `eddie:jordan`
  - `quinn:andrea`

- Connect to FTP:

```bash
ftp <ip> <port>
```

- Retrieve the flag file:

```ftp
get <flag-file>
```
