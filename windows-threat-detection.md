# Windows Threat Detection

## Intro to Initial Access

### Exposed Services

Open ports, exposed to the open internet,  can be scanned by automated bots.  

Example MITRE Techniques:

[T1133 / External Remote Services (opens in new tab)](https://attack.mitre.org/techniques/T1133/): Threat actors will look for exposed RDP/VNC/SSH with weak passwords to get remote access to the machine
[T1190 / Exploit Public-Facing Application (opens in new tab)](https://attack.mitre.org/techniques/T1190/): Threat actors will look for misconfigured or vulnerable websites and applications

### User-Driven Methods

 Clicking malicious links  
 Launching phishing attachments  
 use of pirated software  
 Picking up / inserting unknown USB devices

 Example MITRE Techniques: 

[T1566 / Phishing](https://attack.mitre.org/techniques/T1566/): Threat actors employ different techniques, tricking users into launching the malware themselves
[T1091 / Removable Media](https://attack.mitre.org/techniques/T1091/): Threat actors infect a USB device and hope that users will use the USB on multiple PCs

## Inital Access via RDP

### Risks of Exposed RDB

### Detecting RDP Breach

| # | Step of Attack              | Description                                                                 | Detection Opportunity |
|---|----------------------------|-----------------------------------------------------------------------------|------------------------|
| 1 | Network Scan               | Botnet scans our IP and detects an exposed port                            | N/A. Network attacks are out of the room scope |
| 2 | Brute Force                | Botnet starts a brute force of common usernames (Administrator, admin, support, etc.) | 1. Open Security logs and filter for failed logins (Event ID 4625) <br> 2. Filter for logon types 3 and 10 (remote logons) <br> 3. Filter for logins from external sources (use "Source IP" field) <br> 4. This indicates a potential brute force |
| 3 | Initial Access             | After ~100 attempts, the botnet guesses the correct password and enters the system | 1. Continue from previous step <br> 2. Switch filter to Event ID 4624 (successful logins) <br> 3. Check the account used for login <br> 4. Identify which account enabled initial access |
| 4 | Further Malicious Actions  | Two hours after the breach, the threat actor logs in and reviews the Desktop | 1. Continue from previous step <br> 2. Filter for logon type 10 (interactive login) <br> 3. Copy the "Logon ID" from the event <br> 4. Search logs for the same "Logon ID" <br> 5. Review all processes started by the threat actor |

### Logging Brute Force

## Initial Access via Phishing

## Initial Access via USB