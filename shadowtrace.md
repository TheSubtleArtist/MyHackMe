# Shadow Trace

It’s the middle of the night shift. You’re the only analyst in the SOC when a manager calls in urgently: a suspicious file was found on a user's machine and needs immediate review.

You open the file and start digging. Something doesn’t look normal for a company updater, and at the same time, the EDR throws a couple of alerts.

Your task: analyse the file, collect anything to identify it, gather any potential IOCs, correlate and analyse the alerts for potential malicious behaviour. It’s up to you to piece together what’s happening before it spreads further.

## File Analysis

### What is the architecture of the binary file windows-update.exe?

### What is the hash (sha-256) of the file windows-update.exe?

### Identify the URL within the file to use it as an IOC

### With the URL identified, can you spot a domain that can be used as an IOC?

### Input the decoded flag from the suspicious domain

### What library related to socket communication is loaded by the binary?

## Alert Analysis

### Can you identify the malicious URL from the trigger by the process powershell.exe?

### Can you identify the malicious URL from the alert triggered by chrome.exe?

### What's the name of the file saved in the alert triggered by chrome.exe?