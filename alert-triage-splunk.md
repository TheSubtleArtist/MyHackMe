# Alert Triage with Splunk

## Introduction

Learning Objectives

Learn how to properly investigate alerts in a SOC environment.
Understand how to investigate brute-force attacks on Linux systems.
Discover the persistence mechanism on Windows systems.
Analyse a web shell on a vulnerable web server.
Learn how to investigate alerts for three given scenarios using Splunk.

## Initial Access Alert

### Alert Scenario

An alert about a possible brute force attack appeared on the platform.

Alert Details:

- Alert Name: Brute Force Activity Detection
- Time: 17/09/2025 9:00:21 AM
- Target Host: tryhackme-2404
- Source IP: 10.10.242.248
- search index: `index=linux-alert`

### Investigating the Alert

Source IP: 
- local IP address
- suggests attacker is already inside the organization's network
- organization's VPN or other device is compromised
- An asset inventory would reveal the role of the device associated with the IP address, if the inventory exists.

Alert Time is during regular working hours  

Move to the SIEM to investigate the potential existence of a brute force attack

```spl
index='Linux-alert" sourcetype="linux_secure" 10.10.242.248
| search "Accepted password for" OR "Failed password for" OR "Invalid user"
| sort + _time
```


Observe a large number of events associated with the IP  
Several login attemps for non-existent users  

![triage-1](assets/alert-triage-splunk-101.svg)  

currently no evidence of brute force attempts.  
Maybe the use of invalid users is being used to hide aggregation of activities  

```spl
index="linux-alert" sourcetype="linux_secure" 10.10.242.248
| rex field=_raw "^\d{4}-\d{2}-\d{2}T[^\s]+\s+(?<log_hostname>\S+)"
| rex field=_raw "sshd\[\d+\]:\s*(?<action>Failed|Accepted)\s+\S+\s+for(?: invalid user)? (?<username>\S+) from (?<src_ip>\d{1,3}(?:\.\d{1,3}){3})"
| eval process="sshd"
| stats count values(src_ip) as src_ip values(log_hostname) as hostname values(process) as process by username
```

Observations:
- login attempts from the IP targeted for differnt users.  
- only `john.smith` has a high number of 503 attempts, clearly indicating a brute force attack  
- does not reveal whether `john.smith` successfully gained access  

![triage-2](assets/alert-triage-splunk-102.svg)  

Attempt to search for successful logins  

```spl
index="linx-alert" sourcetype="linux_secure" 10.10.242.248  
| rex field=_raw "^\d{4}-\d{2}-\d{2}T[^\s]+\s+(?<log_hostname>\S+)"
| rex field=_raw "sshd\[\d+\]:\s*(?<action>Failed|Accepted)\s+\S+\s+for(?: invalid user)? (?<username>\S+) from (?<src_ip>\d{1,3}(?:\.\d{1,3}){3})"
| eval process="sshd"
| stats count values(action) values(src_ip) as src_ip values(log_hostname) as hostname values(process) as process  by username
```

Observations:
- successful login only for `john.smith`
- indicates successful brute force attack
- attacker gained access to tryhackme-2404  
- True Positive  
- Escalate to L2  

![triage-3](assets/alert-triage-splunk-103.svg)

### Initial Access Alert Questions

#### How many failed login attempts were made on the user john.smith?

`index="linux-alert" src_ip="10.10.242.248" "failed" AND "john.smith"`  

#### What was the duration of the brute force attack in minutes?

5 minutes

#### What username was the attacker able to privilege escalate to?

`index="linux-alert" user="john.smith" uid=0`

#### What is the name of the user account created by the attacker for persistence?  

`index="linux-alert" "adduser" OR "useradd" USER=root`


## Persistence Alert

### Alert Scenario  

An alert has come through indicating that a suspicious scheduled task was created on a host.

Alert Details:

  - Alert Name: Potential Task Scheduler Persistence Identified
  - Time: 30/08/2025 10:06:07 AM
  - Host: WIN-H015
  - User: oliver.thompson
  - Task Name: AssessmentTaskOne
  - Search index = `index=win-alert`

### Investigating the Persistence Alert

**Host**  
- What kind of host? Workstation or server?
- Is there an asset inventory and naming convention whic reveals information?

**User**  
- does the activity fit the user's role in the organizaiton?  e.g.: IT admins create scheduled tasks, not likely true of HR teams.  
- does the user's location and time correspond with working hours / locations?

```spl
index="win-alert" EventCode=4698 AssessmentTaskOne
| table _time EventCode user_name host Task_Name Message
```

The search reveals only a single event  

![alert-4](assets/alert-triage-splunk-104.png)  

Review the details of the event  

Three sections matter: Triggers, exec, and Pricipals  

Triggers: The event runs once per day at the same time every day, from a specific user workstation.  

![triggers](assets/alert-triage-splunk-105.svg)  

![exec-principals](assets/alert-triage-splunk-106.svg)  

The image used is `certutil`.
The action: download `rv.exe` from `tryhotme` domain  
destination: `temp` folder
outfile name: `DataCollector.exe`  
launch: `Start-Process` PowerShell command
user: `oliver.thompson` 

Analysis: Persistence  
Result: True Positive  

### Persistence Questions

#### What is the ProcessId of the process that created this malicious task?

```spl
index="win-alert" AssessmentTaskone 
|  table ParentProcessID ProcessID CommandLine
```

#### What is the name of the parent process for the process that created this malicious task?

```spl
index="win-alert" AssessmentTaskone 
|  table ParentProcessID ProcessID CommandLine
```
#### Which local group did the attacker enumerate during discovery?

`index="win-alert" "cmd.exe" AND "oliver.thompson" CommandLine=*localgroup*`

#### What is the name of the workstation from which the Threat Actor logged into this host?

`index="win-alert" WIN-H015 TaskCategory=Logon OR TaskCategory="Special Logon" app="win:remote" 
|  table Message`

## Web Shell Alert

### Alert Scenario

Alert Details:

    Alert Name: Potential Web Shell Upload Detected
    Time: 14/09/2025 09:31:51 AM
    Resource: http://web.trywinme.thm
    Suspicious IP: 171.251.232.40
    search index: index=web-alert

### Investigating teh Web Alert

Indicators which can be investigtaed include the URL and the suspicious IP.

Can use the [AbuseIPDB](https://www.abuseipdb.com/check/171.251.232.40) threat intelligence platforms to investigate.  

The IP has been flagged as malicious more than 3000 times.

![intelligence](assets/alert-triage-splunk-107.png)  

Investigate logs for activity by the ip address  

```spl
index=web-alert 171.251.232.40
| table _time clientip useragent uri_path method status 
| sort + _time
```

![query-ip](assets/alert-triage-splunk-108.svg)  

Observations:
- many requests assocaited with the IP
- User-Agent: Hydra (common tool for brute force)
- attack surface: `wp-login.php`  
  
This indicates a brute force attack. 

Next, exclude the brute force activity to see what else might be going on. 

Exclude "hydra" as a user-agent:  

```spl
index=web-alert 171.251.232.40 useragent!="Mozilla/5.0 (Hydra)" 
| table  _time clientip useragent uri_path referer referer_domain method status
```  

![exclude-hydra](assets/alert-triage-splunk-109.svg)  

Observations:
- A post requested for `admin-ajax.php`  
- referer pointing to `theme-editor.php?file=b374k.php`  

Analysis: a theme editor should not be referring to an arbitrary .php file. Legitmate OS utilty would refer to only OS files. This indicates an upload.  
Assumption: an uploaded file is likely a reverse shell.  

Investigaate the `b374k..php` file  

```spl
index=web-alert 171.251.232.40 b374k.php
| table _time clientip useragent uri_path referer referer_domain method status
| sort + _time
```

Indicator: threat actor gains access to possible web shell file and executing activity through it.  
there are successful POST reqests  
Logs do not show how the threat actor initallly uploaded the web shel to the server  

![file](assets/alert-triage-splunk-110.svg)  

Threat actors may use a popular webshell without making any edits.  Use OSINT to discover information  

![osint](assets/alert-triage-splunk-111.png)  

Findings:
- the IP address is Vietnamese
- the target is a web server
- the file is a web-shell
- threat actor used Hydra to attack wp-login.php
- True Positive.

### Web Shell Questions 

#### What time did the brute-force activity using Hydra begin?
Answer Format Example: 2025-01-15 12:30:45

```spl
index="web-alert" useragent=*hydra* 
|  sort +_time
```

#### Which user agent did the attacker use when interacting with the web shell?

```spl
index="web-alert" theme-editor.php 
| table useragent
```

#### What was the number of requests made by the attacker to the server via the web shell?

`index="web-alert" b374k.php`

Make sure only to count the requests to the correct .php, not all the requests involving the web shell.