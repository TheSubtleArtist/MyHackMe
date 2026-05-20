# Windows Event Logs

_Source timestamp: Friday, May 12, 2023, 12:18 PM_

> Converted from a OneNote Word export into Markdown for rapid cybersecurity reference. Commands and lab steps are preserved from the source notes; use only in authorized lab or assessment environments.

Windows Event IDs: https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/

DEFINED

- record events taking place in the execution of a system

- provides audit trail to understand activity and/or diagnose problems

- combine logs from multiple sources for statistical analyses; identify correlations among "unrelated" events

### Event Viewer

- Microsfot Management Console

- drill down to desired system or application

- logs have properties: including log path, max size, enable/disable log, clear log, etc…

- Level: level of severeity: Information, Warning, Error, Verbose,

- Date and Time: when the event was lgged

- Source:specific appliation or component causing the event to be logged

- Event ID: predefined numerical value; maps to specific operation or event based on the log source

- Task Category: supports organizing events for filetering; event sources defines the column

```text
POWERSHELL WINDOWS EVENTS COMMAND LINE UTILITY (WEVTUTIL)
```

- retrieve information about event logs and publishers; installs and uninstalls event manifests; runs queries; exports, archives, and clears log

- help: wevtutil.exe /?

- help for a specific command: wevtutil.exe <COMMAND> /?

- best to run the app inside of powershell to pipe commands

```text
"wevtutil.exe el | Measure-Object ///enumerates the logs and then provides some statistics, specifically counting.
```

```text
POWERSHELL GET-WINEVENT
```

### gets events from event logs and event tracing log files on local and remote computers

### can combine multiple events from multiple sources into single command

### filters using XP_ath queries, structured XML queries, and hash table queries

```text
GET-WINEvent -ListLog *
GET-WINEvent -ListProvider *
GET-WINEvent -LogName Application | Where-Object {_.ProviderName -Match 'WLMS'}
```

- Resource: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent?view=powershell-7.3&viewFallbackFrom=powershell-7.1

### Xml Path Language

- provides standard syntax for addressing parts of an XML document and manipulating strings, numbers, and booleans

- Windows event Log supports a subset of Xpath 1.0

- useable with GET-WINEVENT and WEVTUTIL

- Reference: https://learn.microsoft.com/en-us/previous-versions/dotnet/netframework-4.0/ms256115(v=vs.100)

- Windows Logging Cheat Sheet: https://static1.squarespace.com/static/552092d5e4b0661088167e5c/t/580595db9f745688bc7477f6/1476761074992/Windows+Logging+Cheat+Sheet_ver_Oct_2016.pdf

### Practical Exercise

- The next scenarios/questions are based on the external event log file titled merged.evtx found on the Desktop. You can use any of the aforementioned tools to answer the questions below.

- Scenario 1 (Questions 1 & 2): The server admins have made numerous complaints to Management regarding PowerShell being blocked in the environment. Management finally approved the usage of PowerShell within the environment. Visibility is now needed to ensure there are no gaps in coverage. You researched this topic: what logs to look at, what event IDs to monitor, etc. You enabled PowerShell logging on a test machine and had a colleague execute various commands.

- Scenario 2 (Questions 3 & 4): The Security Team is using Event Logs more. They want to ensure they can monitor if event logs are cleared. You assigned a colleague to execute this action.

- Scenario 3 (Questions 5, 6 & 7): The threat intel team shared its research on Emotet. They advised searching for event ID 4104 and the text "ScriptBlockText" within the EventData element. Find the encoded PowerShell payload.

- Scenario 4 (Questions 8 & 9): A report came in that an intern was suspected of running unusual commands on her machine, such as enumerating members of the Administrators group. A senior analyst suggested searching for "C:\Windows\System32\net1.exe". Confirm the suspicion.

### Answer the questions below

- Started by opening the file in Event Viewer

### What event ID is to detect a PowerShell downgrade attack?

### Googled "Detect Powershell Downgrade Attack"

  - Resource: https://www.leeholmes.com/detecting-and-preventing-powershell-downgrade-attacks/

  - Answer: 400

### What is the Date and Time this attack took place? (MM/DD/YYYY H:MM:SS [AM/PM])

- Helpful Reference: https://kurtroggen.wordpress.com/2017/05/17/powershell-security-powershell-downgrade-attacks/

```text
Get-WinEvent -Path "C:\Users\Administrator\Desktop\merged.evtx | Where-Object Id =400"\
```

- the first return has a time of 12/18/2020 7:50:33 AM

### A Log clear event was recorded. What is the 'Event Record ID'?

### Googled to find out that "Log Clear" event id is 104

### tried the powershell command with id=104, but that was really slow

### Event Viewer gave immediate result in the Details, but had to view XML

  - Answer: 27736

### What is the name of the computer?

- in the same record

- Answer: PC01.example.corp

### What is the name of the first variable within the PowerShell command?

- Scenario 3

- Filter by event ID 4104

- make sure sorted by date/time

- First Entry has several answers

- Answer: $Va5w3n8

### What is the Date and Time this attack took place? (MM/DD/YYYY H:MM:SS [AM/PM])

- Answer: 8/25/2020 10:09:28 PM

### What is the Execution Process ID?

- Answer: 6620

### What is the Group Security ID of the group she enumerated?

- google says enumeration is related to event IDs 4798 and 4799

- figured out the event ID and then used "Find" to search for "Administrators"

- The answer was in the "Target SID" XML data

### What is the event ID?

- tried both 4798 and 4799

- Answer: 4799

### Security Log: Authentication

Two most important Security logs: Successful Logon (4624) and Failed Logon (4625).

| Event ID | Purpose | Logging | Limitations |
| --- | --- | --- | --- |
| 4624<br>(Successful Logon) | Detect suspicious RDP/network logins and identify the attack starting point | Logged on the target machine, the one you are trying to access | Noisy. You will see hundreds of logon events per minute on loaded servers |
| 4625<br>(Failed Logon) | Detect brute force, password spraying, or vulnerability scanning | Logged on the target machine, the one you are trying to access | Inconsistent. The logs have lots of caveats that may trick you into the wrong understanding of the event |

### Usage of 4624/4625

Even experienced IT admins often rely on security experts to distinguish bad from good events, so don't worry if the workbooks below seem complex at first. Take your time and treat this task as fundamental knowledge that you will use in practice for many upcoming rooms!

Detect RDP Brute Force (Expand Me)

- Open Security logs and filter for 4625 event ID (Failed login attempts)

- Look for events with Logon Type 3 and 10 (Network and RDP logins)

  - For most modern systems, the logon type will be 3 (since [NLA](https://superops.com/rmm/what-is-network-level-authentication) is enabled by default)

  - For older or misconfigured systems, the logon type will be 10 (since NLA is not used)

- Every event is now worth your attention, but the main red flags are:

  - Many attempted users like admin, helpdesk, and cctv (Indicates password spraying)

  - Many login failures on a single account, usually Administrator (Indicates brute force)

  - Workstation Name does not match a corporate pattern (e.g. kali instead of THM-PC-06)

  - Source IP is not expected (e.g. your printer trying to connect to your Windows Server)

Analyse RDP Logons (Expand Me)

- Open Security logs and filter for 4624 event ID (Successful logins)

- Look for events with Logon Type 10 (RDP logins)

  - If [NLA](https://superops.com/rmm/what-is-network-level-authentication) is enabled, every RDP logon event is preceded by another 4624 with logon type 3

  - To get a real Workstation Name, you need to check the preceding logon type 3 event

- Your red flags are either a preceding brute force or a suspicious source IP / hostname

- If you assume that the login was indeed malicious, find out what happened next:

  - Windows assigns a Logon ID to every successful login (e.g. 0x5D6AC)

  - Logon ID is a unique session identifier. Save it for future analysis!

### Security Log: User Management

### Overview

common event IDs:

| Event ID | Description | Malicious Usage |
| --- | --- | --- |
| 4720 / 4722 / 4738 | A user account was<br>created / enabled / changed | Attackers might create a backdoor account or even enable an old one to avoid detection |
| 4725 / 4726 | A user account was<br>disabled / deleted | In some advanced cases, threat actors may disable privileged SOC accounts to slow down their actions |
| 4723 / 4724 | A user changed their password /<br>User's password was reset | Given enough permissions, threat actors might reset the password and then access the required user |
| 4732 / 4733 | A user was added to /<br>removed from a security group | Attackers often add their backdoor accounts to privileged groups like "[Administrators](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-security-groups)" |

### Structure of User Management Events

All user management events have a similar structure and can be split into three parts: who did the action (Subject), who was the target (Object), and which exact changes were made (Details):

- Subject: The account doing the action. Note the Logon ID field - you can use it to correlate this event with the preceding 4624 login event!

- Object: This can be named differently depending on an event ID (e.g. New Account or Member), but it always means the same - the target of the action.

- Details: A target group for 4732 and 4733 events, or new user's attributes like full name or password expiration settings for the 4720 event.

### Usage of User Management Events

Many real breaches involved at least some user manipulation events, for example, [these ransomware actors](https://thedfirreport.com/2023/04/03/malicious-iso-file-leads-to-domain-wide-ransomware/) reset all user accounts to a single password to slow down the recovery, and [these attackers](https://thedfirreport.com/2025/02/24/confluence-exploit-leads-to-lockbit-ransomware/) created a new admin account for persistence. Refer to the workbooks below to learn how to hunt for similar attacks:

Hunt for Backdoored Users (Expand Me)

- Open Security logs and filter for 4720 / 4732 event IDs

- Manually review every event; your red flags are:

  - No one from your IT department can confirm the action

  - Changes were made during non-working hours or on weekends

  - The subject user's name is unknown or unexpected to you
(e.g. "adm.old.2008" creating new Windows users)

  - The target user's name does not follow a usual naming pattern
(e.g. "backup" instead of "thm_svc_backup")

- If you confirmed that the action was malicious, find out the login details:

```text
Copy the Logon ID field from your 4720 / 4732 event
```

  - Find the corresponding login event with the same Logon ID

  - Refer to the workbooks from the previous task for further analysis
