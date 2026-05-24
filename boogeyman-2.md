# Boogeyman 2

> Structured cybersecurity study notes converted from the source DOCX. Commands, indicators, answers, and investigation pivots are preserved for rapid reference.

After having a severe attack from the Boogeyman, Quick Logistics LLC improved its security defenses. However, the Boogeyman returns with new and improved tactics, techniques and procedures.
In this room, you will be tasked to analyze the new tactics, techniques, and procedures (TTPs) of the threat group named Boogeyman.
## Investigation Platform

Before we proceed, deploy the attached machine by clicking the Start Machine button in the upper-right-hand corner of the task. It may take up to 3-5 minutes to initialize the services.
The machine will start in a split-screen view. If the VM is not visible, use the blue Show Split View button at the top-right of the page.
Artefacts
## For the investigation, you will be provided with the following artefacts

Copy of the phishing email.
Memory dump of the victim's workstation.
You may find these files in the /home/ubuntu/Desktop/Artefacts directory.
Tools
## The provided VM contains the following tools at your disposal

Volatility - an open-source framework for extracting digital artefacts from volatile memory (RAM) samples.
```text
ubuntu@tryhackme:~
ubuntu@tryhackme$ # Volatility usage:
ubuntu@tryhackme$ vol -f memorydump.raw <plugin>
```

# To list all available plugins
```text
ubuntu@tryhackme$ vol -f memorydump.raw -h
```

Note: Volatility may take a few minutes to parse the memory dump and run the plugin. For plugin reference, check the Volatility 3 documentation.
Olevba - a tool for analyzing and extracting VBA macros from Microsoft Office documents. This tool is also a part of the Oletools suite.
## From <https://tryhackme.com/room/boogeyman2>

## The Boogeyman is back!

Maxine, a Human Resource Specialist working for Quick Logistics LLC, received an application from one of the open positions in the company. Unbeknownst to her, the attached resume was malicious and compromised her workstation.
![The Boogeyman is back!](assets/boogeyman-2-101.png)

The security team was able to flag some suspicious commands executed on the workstation of Maxine, which prompted the investigation. Given this, you are tasked to analyze and assess the impact of the compromise.
## Questions and Answers

### What email was used to send the phishing email?

- Open the email with the provided application
- **Answer:** westaylor23@outlook.com
### What is the email of the victim employee?

- **Answer:** maxine.beck@quicklogisticsorg.onmicrosoft.com
### What is the name of the attached malicious document?

```text
grep -i attachment Resume\ -\ Application\ for\ Junior\ IT\ Analyst\ Role.eml
```

- Answer revealed
- **Answer:** Resume_WesleyTaylor.doc
### What is the MD5 hash of the malicious attachment?

- use the installed mail browser to download the attachment
```text
mdfsum Resume_WesTayulor.doc
```

- **Answer:** 52c4384a0b9e248b95804352ebec6c5b
### What URL is used to download the stage 2 payload based on the document's macro?

```text
olevba <resume file>
```

- Answer appears near the top of the windows
- **Answer:** > https://files.boogeymanisback.lol/aa2a9c53cbb80416d3b47d85538d9971/update.png
### What is the name of the process that executed the newly downloaded stage 2 payload?

- in the window of results from the previous question
- **Answer:** wscript.exe
### What is the full file path of the malicious stage 2 payload?

- in the window of results from the olevba command
- **Answer:** C:\ProgramData\update.js
### What is the PID of the process that executed the stage 2 payload?

- first, copied the memory file to mem.raw
- second, used volatility
```text
vol -f mem.raw windows.pstree | grep -I wscript"
```

- **Answer:** 4260
### What is the parent PID of the process that executed the stage 2 payload?

```text
vol -f mem.raw windows.pstree | grep -I 4260
```

- note that the parent process ID is the second column
- **Answer:** 1124
### What URL is used to download the malicious binary executed by the stage 2 payload?

- in the window of results from the olevba command
- **Answer:** https://files.boogeymanisback.lol/aa2a9c53cbb80416d3b47d85538d9971/update.exe
### What is the PID of the malicious process used to establish the C2 connection?

```text
vol -f mem.raw windows.netscan > netscan // dump to an external file to make it easier to work with
```

- looked through the file. There is a connection on port 8080 and the process id is 6216
- **Answer:** 6216
### What is the full file path of the malicious process used to establish the C2 connection?

```text
vol -f mem.raw windows.dlllist --pid > dllList
cat dllList | grep 6216
```

- Choosing the first instance is the likely choice. It's where the file is probably actually located
- **Answer:** C:\Windows\Tasks\updater.exe
### What is the IP address and port of the C2 connection initiated by the malicious binary? (Format: IP address:port)

```text
vol -f mem.raw windows.netscan > netDump
cat netDump | grep updater.exe
```

- **Answer:** 128.199.95.189:8080
### What is the full file path of the malicious email attachment based on the memory dump?

```text
vol -f mem.raw windows.filedump > fileDump
cat fileDump | grep -I "resume"
```

- **Answer:** \Users\maxine.beck\AppData\Local\Microsoft\Windows\INetCache\Content.Outlook\WQHGZCFI\Resume_WesleyTaylor (002).doc
### The attacker implanted a scheduled task right after establishing the c2 callback. What is the full command used by the attacker to maintain persistent access?

```text
vol -f WKSTN-2961.raw windows.memmap --dump --pid 6216 // dumps to a file named for the pid
cp pid.6216.dmp mem.dmp
strings mem.dmp > memStrings
cat memStrings | grep -i schtasks // schtasks is the windows native information and revals only a couple lines which cannot be the correct answer, which is quite long
strings mem.raw > imageStrings // should have been one of the first steps in this exercise
cat imageStrings | grep -I schtasks
```

- **Answer:** chtasks /Create /F /SC DAILY /ST 09:00 /TN Updater /TR 'C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -NonI -W hidden -c \"IEX ([Text.Encoding]::UNICODE.GetString([Convert]::FromBase64String((gp HKCU:\Software\Microsoft\Windows\CurrentVersion debug).debug)))\
