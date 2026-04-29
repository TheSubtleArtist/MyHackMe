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
| 1 | Network Scan               | Botnet scans our IP and detects an exposed RDB port                            | N/A. Network attacks are out of the room scope |
| 2 | RDP Brute Force                | Botnet starts a brute force of common usernames (Administrator, admin, support, etc.) | 1. Open Security logs and filter for failed logins (Event ID 4625) <br> 2. Filter for logon types 3 and 10 (remote logons) <br> 3. Filter for logins from external IP sources (use "Source IP" field) <br> 4. This indicates a potential RDP brute force |
| 3 | Initial Access via RDP            | After ~100 attempts, the botnet guesses the correct password and enters the system | 1. Continue from previous step <br> 2. Switch filter to Event ID 4624 (successful logins) <br> 3. Check the account used for login <br> 4. Identify which account enabled initial access |
| 4 | Further Malicious Actions  | Two hours after the breach, the threat actor logs in via RDB and reviews the Desktop | 1. Continue from previous step <br> 2. Filter for logon type 10 (interactive RDP login) <br> 3. Copy the "Logon ID" from the event <br> 4. Search Sysmon logs for the same "Logon ID" <br> 5. Review all processes started by the threat actor |via RDP

### Logging Brute Force

![Logging-brute-force](images/intro-initial-access-103.png)  

## Initial Access via Phishing

### Current State of Phishing

Phishing attacks have increased at least 41x since the release of ChatGPT in 2022.  
High seccess rate  

### Binary Attachments

People are weary not to open unfamiliar `.exe` files.  
People are less familiar with less common extensions: `com`; `.scr`. or `.cpl`  
All have potential to carry and distribute malware  

Windows hides known file extensions by defult; allows attackers to miss malicious file extensions: `fake-invoice.pdf.exe`  

### LNK Attachments

Common method: make scripts look trustworthy by hiding them behind LNK shortcuts.  
Inserting malicious scripts as the "target"  

![lnk-target](images/intro-initial-access-104.png)  

### Detecting Malicious Download

## Initial Access via USB