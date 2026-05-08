# Shadow Trace

It’s the middle of the night shift. You’re the only analyst in the SOC when a manager calls in urgently: a suspicious file was found on a user's machine and needs immediate review.

You open the file and start digging. Something doesn’t look normal for a company updater, and at the same time, the EDR throws a couple of alerts.

Your task: analyse the file, collect anything to identify it, gather any potential IOCs, correlate and analyse the alerts for potential malicious behaviour. It’s up to you to piece together what’s happening before it spreads further.

## File Analysis

### What is the architecture of the binary file windows-update.exe?

Using the available Git Bash window... 
`:> file windows-update.exe` 

The output includes `PE32+` and `x86-64`. Both reveal the answer.

### What is the hash (sha-256) of the file windows-update.exe?

`:> shas256sum windows-update.exe`

### Identify the URL within the file to use it as an IOC

`:> strings windows-update.exe | grep -i http`  

### With the URL identified, can you spot a domain that can be used as an IOC?

`:> strings windows-update.exe > outfile` 

`:> cat -n outfile`  

Since "tryhatme" appears numerous times..

`:> grep -i tryhatme outfile`  


### Input the decoded flag from the suspicious domain

Found on line 1002 of "outfile", encoded in base64

### What library related to socket communication is loaded by the binary?  

DLL files are loaded by binaries...

`:> grep -i dll outfile`  

Easy to identify.  

## Alert Analysis

### Can you identify the malicious URL from the trigger by the process powershell.exe?

Use Cyberchef. 

From Base64  

### Can you identify the malicious URL from the alert triggered by chrome.exe?

From Decimal  

### What's the name of the file saved in the alert triggered by chrome.exe?

Right in front of you.