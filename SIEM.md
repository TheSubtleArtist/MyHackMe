# Network Visibility through SIEM

Security Information and Event Management (SIEM) depends on visibility across hosts, applications, and network activity. Before explaining the value of SIEM, it is important to understand why visibility into network activity matters.

The example network below includes multiple Linux and Windows endpoints, one data server, and one website. Each component communicates with other systems or accesses the internet through a router.

![Network Visibility through SIEM](assets/SIEM-101.png)

Each network component can generate one or more types of logs. For example, a Windows endpoint may use both Windows Event Logs and Sysmon to provide stronger visibility into endpoint activity. Network log sources can be divided into two logical categories:

## 1) Host-Centric Log Sources

Host-centric log sources capture events that occur on, or directly relate to, an individual host.

Common host-centric log sources include:

- Windows Event Logs
- Sysmon
- Osquery

Examples of host-centric events include:

- A user accessing a file
- A user attempting to authenticate
- Process execution activity
- A process adding, editing, or deleting a registry key or value
- PowerShell execution

## 2) Network-Centric Log Sources

Network-centric logs are generated when hosts communicate with each other or access external resources, such as internet-based websites or services.

Common network protocols and services that may generate network-centric logs include:

- SSH
- VPN
- HTTP/HTTPS
- FTP
- Network file sharing protocols

Examples of network-centric events include:

- An SSH connection
- A file accessed through FTP
- Web traffic
- A user accessing company resources through a VPN
- Network file sharing activity

## Importance of SIEM

![Importance of SIEM](assets/SIEM-102.png)

When many devices generate hundreds or thousands of events, reviewing logs on each device individually during an incident becomes inefficient and error-prone. A SIEM helps centralize this information and make it searchable, actionable, and useful for investigations.

A SIEM solution can:

- Ingest logs from multiple sources in near real time
- Correlate related events across hosts, applications, and network sources
- Search and filter large volumes of log data
- Support incident investigation and response
- Provide visibility into current and historical activity

Key SIEM features include:

- Real-time log ingestion
- Alerting on abnormal or suspicious activity
- 24/7 monitoring and visibility
- Early detection of emerging threats
- Data insights and visualization
- Support for investigating past incidents

## Log Sources and Log Ingestion

Every device in a network generates logs when activity occurs. Examples include a user visiting a website, connecting through SSH, or logging into a workstation. The following common systems and devices are typical SIEM log sources.

### Windows Machine

Windows records events that can be viewed through the Event Viewer utility. Windows assigns unique event IDs to different categories of activity, which helps analysts examine, filter, and track security-relevant events.

To view Windows events:

- Open the Windows search bar.
- Search for **Event Viewer**.
- Review the available event logs in the Event Viewer console.

Logs from Windows endpoints are commonly forwarded to a SIEM solution for monitoring, correlation, and improved visibility.

![Windows Machine](assets/SIEM-103.gif)

### Linux Workstation

Linux stores operating system, service, error, authentication, and warning logs in common log directories. These logs can be ingested into a SIEM for continuous monitoring.

Common Linux log locations include:

- `/var/log/httpd`: Contains HTTP request, response, and error logs.
- `/var/log/cron`: Contains events related to cron jobs.
- `/var/log/auth.log` and `/var/log/secure`: Store authentication-related logs.
- `/var/log/kern`: Stores kernel-related events.

Example cron log:

```text
May 28 13:04:20 ebr crond[2843]: /usr/sbin/crond 4.4 dillon's cron daemon, started with loglevel notice
May 28 13:04:20 ebr crond[2843]: no timestamp found (user root job sys-hourly)
May 28 13:04:20 ebr crond[2843]: no timestamp found (user root job sys-daily)
May 28 13:04:20 ebr crond[2843]: no timestamp found (user root job sys-weekly)
May 28 13:04:20 ebr crond[2843]: no timestamp found (user root job sys-monthly)
Jun 13 07:46:22 ebr crond[3592]: unable to exec /usr/sbin/sendmail: cron output for user root job sys-daily to /dev/null
```

### Web Server

Web server logs are important because they record inbound and outbound requests and responses. Monitoring these logs can help identify possible web attacks, unusual requests, scanning activity, and suspicious access patterns.

In Linux, common Apache log locations include:

- `/var/log/apache`
- `/var/log/httpd`

Example Apache logs:



```text
192.168.21.200 - - [21/March/2022:10:17:10 -0300] "GET /cgi-bin/try/ HTTP/1.0" 200 3395
127.0.0.1 - - [21/March/2022:10:22:04 -0300] "GET / HTTP/1.0" 200 2216
```

### Log Ingestion

![Log Ingestion](assets/SIEM-104.png)

Logs provide valuable information that can help identify security issues. Each SIEM solution has its own ingestion methods, but common approaches include agents, Syslog, manual upload, and port forwarding.

#### 1) Agent / Forwarder

An agent or forwarder is a lightweight tool installed on an endpoint or server. It is configured to collect important logs and send them to the SIEM server.

Splunk commonly refers to this type of component as a **forwarder**.

#### 2) Syslog

Syslog is a widely used protocol for collecting log data from systems such as web servers, databases, network appliances, and Linux hosts. Syslog can send real-time data to a centralized destination, including a SIEM.

#### 3) Manual Upload

Some SIEM solutions, including Splunk and ELK-based platforms, allow users to upload offline data for quick analysis. After ingestion, the data is normalized and made available for searching and investigation.

#### 4) Port-Forwarding

A SIEM can also be configured to listen on a specific port. Endpoints or log sources then forward data to the SIEM instance on that listening port.

An example of how Splunk provides multiple log ingestion methods is shown below:

![Log Ingestion](assets/SIEM-105.png)

## Why SIEM

SIEM is used to correlate collected data and detect possible threats. When a threat is detected or a defined threshold is crossed, the SIEM raises an alert. That alert gives analysts a starting point for investigation and response.

SIEM plays an important role in cybersecurity because it helps organizations:

- Detect threats in a timely manner
- Investigate suspicious activity
- Correlate data across multiple systems
- Improve visibility into network infrastructure
- Support response actions based on evidence

## SIEM Capabilities

SIEM is a major component of a Security Operations Center (SOC) ecosystem. A SIEM collects logs, examines events and flows, and checks whether activity matches rule conditions or exceeds a defined threshold.

Common SIEM capabilities include:

- Correlating events from different log sources
- Providing visibility into both host-centric and network-centric activity
- Supporting timely investigation and response to threats
- Enabling threat hunting for activity not detected by existing rules

![SIEM Capabilities](assets/SIEM-106.png)

## SOC Analyst Responsibilities

SOC analysts use SIEM solutions to understand what is happening across the network and to investigate suspicious activity.

Common SOC analyst responsibilities include:

- Monitoring alerts and dashboards
- Investigating suspicious events
- Identifying false positives
- Tuning noisy rules that generate excessive false positives
- Supporting reporting and compliance requirements
- Identifying and closing blind spots in network visibility

## Analysing Logs and Alerts

A SIEM receives security-related logs through agents, port forwarding, Syslog, manual uploads, and other ingestion methods. After logs are ingested, the SIEM searches for suspicious behavior or unwanted patterns using rules configured by analysts or provided by the SIEM platform.

If a rule condition is met, the rule triggers an alert. The alert is then investigated to determine whether it represents actual malicious or unauthorized activity.

## Dashboard

Dashboards are important SIEM components because they summarize large volumes of normalized and ingested data into actionable views. SIEM platforms usually provide default dashboards and allow analysts to create custom dashboards.

Dashboard information may include:

- Alert highlights
- System notifications
- Health alerts
- Failed login attempts
- Event ingestion counts
- Triggered rules
- Top domains visited

An example of a default dashboard in QRadar SIEM is shown below:

![Dashboard](assets/SIEM-107.png)

## Correlation Rules

Correlation rules help detect threats in a timely manner by using logical conditions to identify suspicious patterns. When a condition is met, the SIEM triggers an alert for analyst review.

Examples of correlation rules include:

- If a user has five failed login attempts within 10 seconds, raise an alert for **Multiple Failed Login Attempts**.
- If a login succeeds after multiple failed login attempts, raise an alert for **Successful Login After Multiple Failed Login Attempts**.
- If a user plugs in a USB device, raise an alert when USB use is restricted by company policy.
- If outbound traffic exceeds 25 MB, raise an alert for a potential data exfiltration attempt, depending on company policy and environment baselines.

### How a correlation rule is created

Correlation rules use field-value pairs from normalized logs. This is why normalized log ingestion is important: rules need consistent fields to evaluate activity across different log sources.

#### Use-Case 1: Event Log Cleared

Adversaries may try to clear logs during the post-exploitation phase to hide their activity. Windows Event ID `104` is logged when an event log is cleared.

Rule logic:

```text
IF Log Source = WinEventLog
AND Event ID = 104
THEN trigger alert: Event Log Cleared
```

#### Use-Case 2: WHOAMI Command Execution

Adversaries often run commands such as `whoami` after exploitation or privilege escalation to determine the current user context.

Useful fields for this rule include:

- **Log source:** Identifies the source capturing the event logs.
- **Event ID:** Identifies the event associated with process execution. Windows Event ID `4688` is commonly associated with process creation activity when process creation auditing is enabled.
- **NewProcessName:** Identifies the process name to evaluate in the rule.

Rule logic:

```text
IF Log Source = WinEventLog
AND Event Code = 4688
AND NewProcessName contains "whoami"
THEN trigger alert: WHOAMI Command Execution Detected
```

## Alert Investigation

When monitoring a SIEM, analysts spend much of their time reviewing dashboards and alerts. Dashboards summarize important network and security details, while alerts provide specific events or flows for investigation.

When an alert is triggered, the analyst reviews the associated events and flows, examines the rule logic, and determines which conditions were met. Based on the investigation, the analyst classifies the alert as a true positive or false positive.

Common follow-on actions include:

- If the alert is a false alarm, tune the rule to reduce similar false positives in the future.
- If the alert is a true positive, perform additional investigation.
- Contact the asset owner to validate the activity.
- If suspicious activity is confirmed, isolate the affected host.
- Block suspicious IP addresses when appropriate and authorized by policy.
