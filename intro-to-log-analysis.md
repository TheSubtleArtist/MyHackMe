# Intro to Log Analysis

- [Intro to Log Analysis](#intro-to-log-analysis)
  - [Log Analysis Basics](#log-analysis-basics)
  - [Investigation Theory](#investigation-theory)
  - [Detection Engineering](#detection-engineering)
  - [Log Analysis Tools: Command Line](#log-analysis-tools-command-line)
  - [Log Analysis tools: Regular Expressions](#log-analysis-tools-regular-expressions)
  - [Log Analysis Tools: Cyber Chef](#log-analysis-tools-cyber-chef)
  - [Log Anlaysis Tools: Yara and Sigma](#log-anlaysis-tools-yara-and-sigma)

## Log Analysis Basics


### Importance of Logs

**System Troubleshooting:** Analyzing system errors and warning logs helps IT teams understand and quickly respond to system failures, minimizing downtime, and improving overall system reliability.  
**Cyber Security Incidents:** In the security context, logs are crucial in detecting and responding to security incidents.  
logs, intrusion detection system () logs, and system authentication logs, for example, contain vital information about potential threats and suspicious activities. Performing log analysis helps
teams and Security Analysts identify and quickly respond to unauthorized access attempts, malware, data breaches, and other malicious activities.  
**Threat Hunting:** On the proactive side, cyber security teams can use collected logs to actively search for advanced threats that may have evaded traditional security measures. Security Analysts and Threat Hunters can analyze logs to look for unusual patterns, anomalies, and indicators of compromise (IOCs) that might indicate the presence of a threat actor.  
**Compliance:** Organizations must often maintain detailed records of their system's activities for regulatory and compliance purposes. Regular log analysis ensures that organizations can provide accurate reports and demonstrate compliance with regulations such as GDPR, HIPAA, or PCI DSS.  

### Types of Logs  

**Application Logs:** Messages from specific applications, providing insights into their status, errors, warnings, and other operational details.  
**Audit Logs:** Events, actions, and changes occurring within a system or application, providing a history of user activities and system behavior.  
**Seurity Logs:** Security-related events like logins, permission alterations, activities, and other actions impacting system security.  
**Server Logs:** System logs, event logs, error logs, and access logs, each offering distinct information about server operations.  
**System Logs:** Kernel activities, system errors, boot sequences, and hardware status, aiding in diagnosing system issues.  
**Network Logs:** Communication and activity within a network, capturing information about events, connections, and data transfers.  
**Database Logs:** Activities within a database system, such as queries performed, actions, and updates.  
**Web Server Logs:** Requests processed by web servers, including URLs, source IP addresses, request types, response codes, and more.  

## Investigation Theory

### Timeline

Understanding the sequence of events WITHING systems, devices, and applications  
chronological representation of logged events, ordered based on their occurrence  
crucial role in reconstructing securiyt incidents  

### Timestamp

Understanding and evaluating each log's timestamp, time zone, and format
Need to convert (normalize) timestampts to a consistent time zone

### Super Timelines

consoidated timeline that provides comprehensivie view of events across different systems ,devices, and applciations, and across types of logs
allows understanding of event sequency holistically  

**[Plaso](https://github.com/log2timeline/plaso):** ***super timeline all the things***, is a Python-based engine used by several tools for automatic creation of timelines. Plaso default behavior is to create super timelines but it also supports creating more targeted timelines.

### Data Visualization

Kibana and SPlunk  
converts raw log data into interactive visual represenatasions  

![Data Visualization](assets/intro-log-analysis-101.png)

### Log Monitoring and Alerting

allow teams to proactivly identify threats and immediately respond when an alert is generated.  

### External Research and Threat Intel  

Threat intelligence feeds like [ThreatFox](https://threatfox.abuse.ch/), allow searching log files for known malicious actors' presence.

## Detection Engineering

### Common Log File Locations

```markdown

    Web Servers:
        Nginx:
            Access Logs: `/var/log/nginx/access.log`
            Error Logs: `/var/log/nginx/error.log`
        Apache:
            Access Logs: `/var/log/apache2/access.log`
            Error Logs: `/var/log/apache2/error.log`

    Databases:
        MySQL:
            Error Logs: `/var/log/mysql/error.log`
        PostgreSQL:
            Error and Activity Logs: `/var/log/postgresql/postgresql-{version}-main.log`

    Web Applications:
        PHP:
            Error Logs: `/var/log/php/error.log`

    Operating Systems:
        Linux:
            General System Logs: `/var/log/syslog`
            Authentication Logs: `/var/log/auth.log`

    Firewalls and IDS/IPS:
        iptables:
            Firewall Logs: `/var/log/iptables.log`
        Snort:
            Snort Logs: `/var/log/snort/`
```

### Common Patterns

identifiable artifacts left behind in logs by threat actors or cyber security incidents.  
 
#### Abnormal User Behavior

actions or activities conducted by users that deviate from their typical or expected behavior.  

Organizations employ log analysis solutions that incorporate detection engines and machine learning algorithms to establish normal behavior patterns. Deviations from these patterns or baselines can then be alerted as potential security incidents.  

[Splunk User Behavior Analytics (UBA)](https://www.splunk.com/en_us/products/user-and-entity-behavior-analytics.html)  
[IBM QRadar UBA](https://www.ibm.com/docs/en/qradar-common?topic=app-qradar-user-behavior-analytics)  
[Azure AD Identity Protection](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)  

Multiple failed login attempts  
Unusual login times  
Geographic anomalies  
Frequent password changes  
Unusual user-agent strings  

### Common Attack Signatures  

Identifying common attack signatures in log data is an effective way to detect and quickly respond to threats. Attack signatures contain specific patterns or characteristics left behind by threat actors. They can include malware infections, web-based attacks (SQL injection, cross-site scripting, directory traversal), and more.  

#### SQL Injections

SQL injection attempts to exploit vulnerabilities in web applications that interact with databases. Look for unusual or malformed SQL queries in the application or database logs to identify common SQL injection attack patterns.

Suspicious SQL queries might contain unexpected characters, such as single quotes ('), comments (--, #), union statements (UNION), or time-based attacks (WAITFOR DELAY, SLEEP()). A useful SQLi payload list to reference can be found here (opens in new tab).

In the below example, an SQL injection attempt can be identified by the ' UNION SELECT section of the q= query parameter. The attacker appears to have escaped the SQL query with the single quote and injected a union select statement to retrieve information from the users table in the database. Often, this payload may be URL-encoded, requiring an additional processing step to identify it efficiently.

#### Cross-Site Scripting (XSS)

inject malicious scripts into web pages
logs contain unexpected or unusual inputs

- `<script>` tags
- event handlers: onmouseover, onclick, onerror  

example: 
    10.10.19.31 - - [2023-08-04 16:12:11] "GET /products.php?earch=<script>alert(1);</script> HTTP/1.1" 200 5153

#### Path Traversal

access files and directoreis outside a web applications intended directory structure  
unauthorized access to sensitive data

examples: 
    `../`
    `../../`

Url-Encoded characters appearing in logs:
    `%2E`= `.`
    `%2F`= `/`

example log entry:  

`10.10.113.45 - - [2023-08-05 18:17:25] "GET /../../../../../etc/passwd HTTP/1.1" 200 505`  

## Log Analysis Tools: Command Line

### cat

"concatenate"  

`:> cat <filename>`
`:> cat <filename 1> <filename2> <filenameN>`  

### less

view a file's data page by page  
allows use of arrow, page up, and page down keys

### tail

view the end of a file  

`:> tail -f <logfilename>` : follow the `<logfilename>` in real time  
`:> tail -n XX` : dispaly the last XX number of lines from the file  

### wc

"word count"  
default: output the line count, word count, and character count of the file  

### cut

extract specific columns from files based on specified delimters

`:> cut -d ';' -f 1 <filename>` where

`-d` is the field delimeter
`-f` is the numnber of the field to be sent to stdout

### sort

arranges data in ascending or descending order, based on specified criteria  

overwhelmingly used just prior to the `cut` command  

### uniq

identifies and removes adjacent duplicate lines from sorted input  

### sed

text processing tool  
manipulate, extract, and transoform log data  
does not alter the original file, alters only the output of the command
`\` : escape character  
`-i` : overwrite the file in place  
`>` : redirect the output  

### awk

actual programming language that requires specific study  


### grep

text search tool  
identify releavant log entries by matching specific criterial (keywords, patterns)  

`:> grep -c` : count entries  
`:> grep -n` : include line numbers  
`:> grep -v` : invert the search; return lines NOT containing the pattern

### Command Line Tools Questions 

#### Use cut on the apache.log file to return only the URLs. What is the flag that is returned in one of the unique entries?

`:> cut -d ' ' -f 7 apache.log`  

#### In the apache.log file, how many total HTTP 200 responses were logged?

`:> cut -d ' ' -f 9 apache.log | grep 200 | wc -l`

#### In the apache.log file, which IP address generated the most traffic?

`:> cut -d ' ' -f 1 apache.log | sort | uniq -c`

#### What is the complete timestamp of the entry where 110.122.65.76 accessed /login.php?

`> grep 110.122.65.76 apache.log | grep /login.php`  

## Log Analysis tools: Regular Expressions

abbreviated as regex  
define patterns for searching, matching, and manipulating text data  
patterns are constructed using a combination of special characters that represent matching rules and are supported in many programming languages, text editors, and software.

widely used to extract relevant information, filter data, identify patterns, and process logs before they are forwarded to a centralized system  

### Regular Expressions for Grep  

refer to the apache-ex2.log file within the ZIP file attached to this task  
locate the task files on the AttackBox under /root/Rooms/introloganalysis/task7  

This log file contains log entries from a blog site  
The site is structured so that each blog post has its unique ID, fetched from the database dynamically through the post URL parameter.  
If we are only interested in the specific blog posts with an ID between 10-19, we can run the following grep regular expression pattern on the log file:  

`:> grep -E 'post=1[0-9]' apache-ex2.log`  

`-E` option enables extended pattern matching, allowing the use of regular expressions instead of plain strings.  
The pattern begins by matching the literal text `post=`.  
It then specifies the digit `1` followed by any digit from `0–9` using `[0-9]`.  
Together, `1[0-9]` matches any two-digit number starting with `1` (e.g., 10–19).  

### Regular Expressions for Log Parsing

Regular expressions are essential for log parsing, enabling the extraction of structured data from diverse log formats.  
Engineers can design custom regex patterns to map specific log components to named fields in SIEM systems, making the data easier to query and analyze.

grep regex example: 

`:> user@tryhackme$ grep -E 'post=1[0-9]' apache-ex2.log`

```bash
input {
  ...
}

filter {
  grok {
    match => { "message" => "(?<ipv4_address>\b([0-9]{1,3}\.){3}[0-9]{1,3}\b)" }
  }
}

output {
  ...
}
```

### Regex Questions

#### How would you modify the original grep pattern above to match blog posts with an ID between 20-29?

post=2[0-9]

#### What is the name of the filter plugin used in Logstash to parse unstructured log data?

grok

## Log Analysis Tools: Cyber Chef

CyberChef, developed by GCHQ, is a versatile data analysis tool known as the “Cyber Swiss Army Knife.” It offers over 300 operations for tasks such as encoding/decoding, encryption, hashing, and log parsing. Analysts use customizable “recipes” to process and analyze data efficiently, including extracting information from log files.  

### Regex with CyberChef  

Regular expressions can be used in CyberChef to extract specific data from logs, such as IP addresses from authentication attempts. Using the pattern `\b([0-9]{1,3}\.){3}[0-9]{1,3}\b`, analysts can identify IPv4 addresses, and the “List matches” output option filters results to display only the matched IPs, removing unnecessary log data.
  
### Uploading Fiels in Cyberchef

Files and folders can be uploaded to CyberChef. This provides a convenient way of uploading log files to CyberChef. To do so, click on the box with an arrow pointing inside it. Additionally, CyberChef has operators that allow you to unzip compressed files, such as .tar.gz or .zip.  

### Cyberchef Questions

#### Locate the "loganalysis.zip" file under /root/Rooms/introloganalysis/task8 and extract the contents. Upload the log file named "access.log" to CyberChef. Use regex to list all of the IP addresses. What is the full IP address beginning in 212?

"Extract IP Addresses"  with sort and IPv4


#### Using the same log file from Question #2, a request was made that is encoded in base64. What is the decoded value?

Extractors > REGEX `(?<![A-Za-z0-9+/])[A-Za-z0-9+/]{8,}={0,2}(?![A-Za-z0-9+/])`

`(?<![A-Za-z0-9+/])` — Negative lookbehind to ensure the match is not part of a larger Base64-like string
`[A-Za-z0-9+/]{8,}` — Matches at least 8 Base64 characters (adjustable threshold to reduce false positives)
`={0,2}` — Matches optional padding (= or ==)
`(?![A-Za-z0-9+/])` — Negative lookahead to ensure the string ends cleanly


#### Using CyberChef, decode the file named "encodedflag.txt" and use regex to extract by MAC address. What is the extracted value?

From base64 > extract MAC addresses

## Log Anlaysis Tools: Yara and Sigma

### Sigma

open-source tool  
describes log events in a structured format  
used to identify entries in log files using pattern matching  

YAML syntax for rules  

```yaml
title: Failed SSH Logins
description: Searches sshd logs for failed SSH login attempts
status: experimental
author: CMNatic
logsource: 
    product: linux
    service: sshd

detection:
    selection:
        type: 'sshd'
        a0|contains: 'Failed'
        a1|contains: 'Illegal'
    condition: selection
falsepositives:
    - Users forgetting or mistyping their credentials
level: medium
```

Here’s your content converted into a structured Markdown table:

```markdown
| Key             | Value                                      | Description                                                                                                      |
|-----------------|--------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| title           | Failed Logins                              | This title outlines the purpose of the Sigma rule.                                                               |
| description     | Searches logs for failed login attempts    | This key provides a description that expands on the title.                                                       |
| status          | experimental                               | This key explains the status of the rule. For example, "experimental" means that further testing is required.   |
| author          | CMNatic                                    | The person who wrote the rule.                                                                                   |
| logsource       | product: <br> service:                     | Where the log files that contain the data that we're looking for can be found.                                  |
| detection       |                                            | This key lists what the Sigma rule is looking to find.                                                           |
| a0\|contains    | a0\|contains: 'Failed'                     | In this case, look for all entries with "Failed".                                                                |
| a1\|contains    | a1\|contains: 'Illegal'                    | In this case, look for all entries with "Illegal".                                                               |
| falsepositives  | Users forgetting or mistyping credentials  | Lists cases where this entry may be present but doesn't necessarily indicate malicious behavior.                |
```

### Yara

pattern-matchign tools  
YAML formatted  
identifies information based on bianry and textual patterns  
useful for logs and malware  

IPFinder uses regex to search for IPV4 rules  

```YAML
rule IPFinder {
    meta:
        author = "CMNatic"
    strings:
        $ip = /([0-9]{1,3}\.){3}[0-9]{1,3}/ wide ascii
 
    condition:
        $ip
}
```

```markdown
| Key        | Example                                             | Description                                                                                          |
|------------|-----------------------------------------------------|------------------------------------------------------------------------------------------------------|
| rule       | IPFinder                                            | This key names the rule.                                                                             |
| meta       | author                                              | This key contains metadata. For example, in this case, it is the name of the rule's author.         |
| strings    | $ip = /([0-9]{1,3}\.){3}[0-9]{1,3}/ wide ascii      | This key contains the values that YARA should look for. In this case, it uses REGEX to find IPv4 addresses. |
| condition  | $ip                                                 | If the variable $ip is detected, then the rule should trigger.                                       |
```
