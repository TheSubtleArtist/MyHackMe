# The Hacker Methodology

    Reconnaissance
    Enumeration/Scanning
    Gaining Access
    Privilege Escalation
    Covering Tracks
    Reporting

## Reconnaissance

    Google (specifically Google Dorking)
    Wikipedia
    PeopleFinder.com
    who.is
    sublist3r - a popular, fast Python-based subdomain enumeration tool used by penetration testers to map a domain's external footprint
    hunter.io
    builtwith.com
    wappalyzer

## Enumeration/Scanning

In the scanning and enumeration phase, the attacker is interacting with the target to determine its overall attack surface.

The attack surface determines what the target might be vulnerable to in the Exploitation phase.

- Nmap
- dirb
- dirbuster
- enum4linux
- metsploit
- Burp Suite


## Exploitation

- Metasploit
- Burp Suite  

## Privilege Escalation

Cracking password hashes found on the target  
Finding a vulnerable service or version of a service which will allow you to escalate privilege THROUGH the service  
Password spraying of previously discovered credentials (password re-use)  
Using default credentials  
Finding secret keys or SSH keys stored on a device which will allow pivoting to another machine  
Running scripts or commands to enumerate system settings like 'ifconfig' to find network settings, or the command 'find / -perm -4000 -type f 2>/dev/null' to see if the user has access to any commands they can run as root  

## Covering Tracks

While ethical hackers rarely have a need to cover their tracks, you still must carefully track and notate all of the tasks that you performed as part of the penetration test to assist in fixing the vulnerabilities and recommending changes to the system owner.  

## Reporting

    The Finding(s) or Vulnerabilities
    The CRITICALITY of the Finding
    A description or brief overview of how the finding was discovered
    Remediation recommendations to resolve the finding