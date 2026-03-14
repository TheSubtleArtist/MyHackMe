# Linux Incident Surface

The Linux Incident Surface focuses on all potential points or sources in the Linux system where an incident could occur or traces of incidents could be found.  
This could lead to a security breach, which could also be part of the Linux Attack Surface.

Linux Attack Surface refers to various entry points where an attack or unauthorized attempt could be made to enter the system or gain unauthorized attempts.

We will observe how the attack-related activities could be translated into the incident footprints or indicators of the attack on the Linux system.

## Scenario

Alice and Bob will assist us in completing the learning objectives of this room. Alice is a Red teamer, and Bob is a Blue teamer at Cybertees Pvt Ltd. Alice will help us perform post-exploitation activities. Bob will help us examine various incident surfaces to identify the footprints of the attack.

Username  Ubuntu
Password TryHackMe!  

## Overview

### Attack Surface

all the points of interaction in a Linux system where an adversary might attempt to exploit vulnerabilities to gain unauthorized access or carry out malicious activities. 

Some of the key entry points that could be identified as part of the Linux Attack Surface are:

    Open ports
    Running services
    Running software or applications with vulnerabilities
    Network communication

The primary goal is to minimize the attack surface by reducing potential weaknesses from the areas the attacker could exploit.  

    Identifying and patching the vulnerabilities
    Minimizing the usage of unwanted services
    Check the interfaces where the user interacts
    Minimizing the publically exposed services, applications, ports, etc

### Incident Surface

all the system areas involved in the detection, management, and response to an actual security incident (post-compromise).  

It includes where security breaches may be detected and analyzed and where a response plan must be implemented to mitigate the incident.

The main purpose of identifying the incident surface is to hunt down, detect, respond to, and recover from the incident if it has occurred.  

A security analyst would monitor all areas within the operating system where any traces or footprints of the attack could be found.  

    System logs
    auth.log, syslog, krnl.log, etc
    Network traffic
    Running processes
    Running services
    The integrity of the files and processes

Understanding the incident surface is key to efficiently responding to an ongoing attack, mitigating damage, recovering affected systems, and applying lessons learned to prevent future incidents.

## Processes and Network Communication

Processes and network communication are critical components of incident investigations in any operating system.  
Monitoring and analyzing processes—especially those communicating over the network—can help identify and respond to security incidents.  
Running processes are an important part of the Linux Incident Surface because they may provide evidence of malicious activity.

### Investigating Processes

To understand the role of processes within the Linux Incident Surface, complete the following exercises.

### Activity 1: Create and Run a Simple Process

In the `/home/activities/processes` directory, there is a source file named `simple.c`. This program can be compiled and executed to create a running process. After running it, we will attempt to locate traces of the process on the system.

**Note:** All commands should be executed as the `root` user.

```bash
sudo su
```

#### 1) Compiling the Code

Compile the source code and create an executable program.

```bash
gcc simple.c -o /tmp/simple
```

This command creates an executable file named `simple` in the `/tmp` directory.

Compiling and Running the Process

`:> root@tryhackme:/home/activities/processes# gcc simple.c -o /tmp/simple`  

`:> root@tryhackme:/home/activities/processes# /tmp/simple`

After compiling and executing the program from `/tmp/`, keep the process running and open a new terminal.

#### 2) Detecting the Footprints

Use the `ps` tool to examine running processes on the Linux host. This tool provides a snapshot of active processes.

```bash
ps aux
```

`ps aux` displays all processes for all users in a detailed format.

Flags:

- `a` — Shows processes for all users  
- `u` — Displays user-oriented format (includes user and start time)  
- `x` — Includes processes not attached to a terminal (useful for background processes)

#### Filtering the Output

To locate the `simple` process, filter the results:

```bash
ps aux | grep simple
```

The output contains the following information:

- `USER` — User who owns the process  
- `PID` — Process ID  
- `%CPU` — CPU usage percentage  
- `%MEM` — Memory usage percentage  
- `VSZ` — Virtual memory size  
- `RSS` — Resident Set Size (actual memory in use)  
- `TTY` — Terminal associated with the process  
- `STAT` — Process state (`R` running, `S` sleeping, `Z` zombie, etc.)  
- `START` — Start time of the process  
- `COMMAND` — Command used to start the process  

#### Examining Files Associated with the Process

Use the `lsof` tool to inspect files and resources connected to the process. This command requires the process `PID`.

Example PID: `49782`

```bash
lsof -p 49782
```

The output reveals files, shared libraries, and other resources associated with the process.

### Process with Network Connection

In many incident scenarios, processes communicating with external systems should be investigated.

To demonstrate this, execute a program named `netcom` located in the `/home/activities/processes` directory.  
This program establishes a network connection to a remote IP address.

```bash
./netcom
```

### Investigating Network Communication

First confirm that the process is running.

```bash
ps aux | grep netcom
```

The output confirms the process is running and displays its `PID` (example: `267490`). The PID will differ in your environment.

Use `lsof` to identify active network connections.

```bash
lsof -i -P -n
```

- `lsof` — Lists open files associated with processes  
- `-i` — Displays network connections (sockets and network files)  
- `-P` — Shows port numbers instead of service names  
- `-n` — Displays IP addresses without resolving them to hostnames  

#### Utilizing Osquery

Another useful tool for investigating processes and network connections is `osquery`.

Start the interactive shell with root privileges:

```bash
osqueryi
```

Use the following query to identify network connections associated with the process PID:

Osquery command:

```sql
SELECT pid, fd, socket, local_address, remote_address
FROM process_open_sockets
WHERE pid = 267490;
```

This query returns socket and network address information associated with the specified process.

### Where Processes Fit in the Linux Incident Surface

Processes can be exploited, manipulated, or used by attackers to execute malicious activity.  
Investigating running processes from multiple perspectives is an important part of incident response.

Examples of potentially suspicious scenarios include:

- A process executing from the `/tmp` directory (context matters)  
- Suspicious parent-child process relationships  
- Processes communicating with suspicious external IP addresses  
- Orphan processes (no parent process after execution)  
- Processes executed through `cron` jobs  
- System binaries running from `/tmp` or user directories  

## Persistence

Persistence generally refers to techniques used by adversaries to maintain access to a compromised system after the initial exploitation. To understand how incidents appear across different parts of a Linux endpoint, we will simulate attacker actions and then examine where the attack footprints appear.

### Taking Foothold

Investigating persistence mechanisms is important because attackers often establish persistence shortly after gaining access to a system.

Some attack techniques that can create persistence on a Linux system are described below.

### Activity 1: Account Creation

In a simulated compromise scenario, assume the role of **Alice**, an attacker who has gained access to the system. The attacker creates a backdoor account.

```bash
sudo useradd attacker -G sudo
sudo passwd attacker
echo "attacker ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers
```

These commands create a new user account named `attacker` and add it to the `sudo` group.

***Creating Backdoor Account***

    ubuntu@tryhackme:/home$ sudo useradd attacker -G sudo
    ubuntu@tryhackme:/home$ sudo passwd attacker
    New password:
    Retype new password:
    passwd: password updated successfully
    ubuntu@tryhackme:/home$ echo "attacker ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers
    attacker ALL=(ALL:ALL) ALL

#### Identifying the Footprints

Now assume the role of **Bob**, a blue team investigator examining the system for signs of compromise.

#### Examining Logs

One of the first places to investigate is system logs, usually in the `/var/log/` directory.

`> ubuntu@tryhackme:/home$ cd /var/log/`  

`:> ubuntu@tryhackme:/var/log$ ls -al`  

    total 3108
    drwxrwxr-x  16 root              syslog             4096 Sep  5 00:00 .
    drwxr-xr-x  14 root              root               4096 Feb 27  2022 ..
    -rw-r--r--   1 root              root              35148 Aug 20 07:34 Xorg.0.log
    -rw-r--r--   1 root              root             116188 Feb 16  2024 Xorg.0.log.old
    -rw-r--r--   1 root              root                  0 Sep  1 00:00 alternatives.log
    -rw-r--r--   1 root              root               8021 Aug 22 06:57 alternatives.log.1
    -rw-r--r--   1 root              root               3001 Feb 16  2024 alternatives.log.2.gz
    drwxr--r-x   3 root              root               4096 Feb 27  2022 amazon
    -rw-r-----   1 root              adm                   0 Aug 20 07:34 apport.log
    -rw-r-----   1 root              adm                 398 Feb 16  2024 apport.log.1
    drwxr-xr-x   2 root              root               4096 Sep  5 06:52 apt
    -rw-r-----   1 syslog            adm               46892 Sep  5 21:30 auth.log
    -rw-r-----   1 syslog            adm               72850 Aug 31 23:30 auth.log.1
    -rw-r-----   1 syslog            adm                3325 Aug 24 23:30 auth.log.2.gz
    -rw-r-----   1 syslog            adm                9404 Aug 20 07:34 auth.log.3.gz
    -rw-rw----   1 root              utmp                  0 Sep  1 00:00 btmp
    -rw-rw----   1 root              utmp               3840 Aug 27 14:04 btmp.1
    -rw-r-----   1 root              adm               44217 Aug 20 07:34 cloud-init-output.log
    -rw-r-----   1 syslog            adm             1576538 Aug 20 07:34 cloud-init.log
    drwxr-xr-x   2 root              root               4096 Sep  5 00:00 cups
    drwxr-xr-x   2 root   `           root               4096 Oct  7  2020 dist-upgrade

#### Examining `auth.log`

Search the authentication logs for account creation events.

```bash
cat auth.log | grep useradd
```

***Examining `auth.log`***

    ubuntu@tryhackme:/var/log$ sudo su
    root@tryhackme:/var/log# cat auth.log | grep useradd
    Sep  5 21:18:19 tryhackme sudo:   ubuntu : TTY=pts/0 ; PWD=/home ; USER=root ; COMMAND=/usr/sbin/useradd attacker -G sudo
    Sep  5 21:18:19 tryhackme useradd[184928]: new group: name=attacker, GID=1001
    Sep  5 21:18:19 tryhackme useradd[184928]: new user: name=attacker, UID=1001, GID=1001, home=/home/attacker, shell=/bin/sh, from=/dev/pts/0
    Sep  5 21:18:45 tryhackme sudo:   ubuntu : TTY=pts/0 ; PWD=/home ; USER=root ; COMMAND=/usr/sbin/useradd attacker -G sudo

These log entries indicate that a new user account was created.

#### Examining `/etc/passwd`

The `/etc/passwd` file contains information about all system users.

```bash
cat /etc/passwd
```

***Examining `/etc/passwd`***

`:> root@tryhackme:/var/log# cat /etc/passwd`

    kernoops:x:113:65534:Kernel Oops Tracking Daemon,,,:/:/usr/sbin/nologin
    lightdm:x:114:121:Light Display Manager:/var/lib/lightdm:/bin/false
    whoopsie:x:115:123::/nonexistent:/bin/false
    dnsmasq:x:116:65534:dnsmasq,,,:/var/lib/misc:/usr/sbin/nologin
    avahi-autoipd:x:117:124:Avahi autoip daemon,,,:/var/lib/avahi-autoipd:/usr/sbin/nologin
    usbmux:x:118:46:usbmux daemon,,,:/var/lib/usbmux:/usr/sbin/nologin
    rtkit:x:119:125:RealtimeKit,,,:/proc:/usr/sbin/nologin
    ----------------------------
    avahi:x:120:126:Avahi mDNS daemon,,,:/var/run/avahi-daemon:/usr/sbin/nologin
    fwupd-refresh:x:130:136:fwupd-refresh user,,,:/run/systemd:/usr/sbin/nologin
    attacker:x:1001:1001::/home/attacker:/bin/sh

Information stored in this file includes:

- `Username`
- Password placeholder (`x` or `*`) indicating the password is stored in `/etc/shadow`
- `User ID (UID)`
- `Group ID (GID)`
- User home directory
- Default shell path

### Activity # 2 Cron Job

Another persistence technique is creating scheduled tasks using **cron**.  
Cron is a time-based job scheduler used to execute commands or scripts automatically at defined intervals.

To modify scheduled jobs:

```bash
crontab -e
```

This opens the user's crontab file for editing.

#### Examples of Crontab Entries

- Execute a script on system reboot: `:> @reboot /path/to/malicious/script.sh`

- Execute a script every minute as `root`: `:> * * * * * root /path/to/malicious/script.sh`  

***Adding a cronjob***

    # Edit this file to introduce tasks to be run by cron.
    #
    # Each task to run has to be defined through a single line
    # indicating with different fields when the task will be run
    # and what command to run for the task
    #
    # To define the time you can provide concrete values for
    # minute (m), hour (h), day of month (dom), month (mon),
    # and day of week (dow) or use '*' in these fields (for 'any').
    #
    # Notice that tasks will be started based on the cron's system
    # daemon's notion of time and timezones.
    #
    # Output of the crontab jobs (including errors) is sent through
    # email to the user the crontab file belongs to (unless redirected).
    #
    # For example, you can run a backup of all your user accounts
    # at 5 a.m every week with:
    # 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
    #
    # For more information see the manual pages of crontab(5) and cron(8)
    #
    # m h  dom mon dow   command
    @reboot /path/to/malicious/script.sh

#### Examining Malicious Cronjobs

Cron jobs associated with users can be examined in `/var/spool/cron/crontabs/[username]`


### Activity 2 Services

Another persistence method is installing a background **service** that runs automatically on system startup.

#### Step 1: Create a Configuration File

```bash
sudo nano /etc/systemd/system/suspicious.service
```

Add the following configuration:


    [Unit]
    Description=Suspicious_Service
    After=network.target

    [Service]
    ExecStart=/home/activities/processes/suspicious
    Restart=on-failure
    User=nobody
    Group=nogroup

    [Install]
    WantedBy=multi-user.target

Key fields:

- `ExecStart` — Command executed by the service
- `Restart=on-failure` — Restarts the service if it fails
- `User` / `Group` — Specifies the account running the service

#### Step 2: Enable and Start Service

Reload the systemd configuration: `:> sudo systemctl daemon-reload`

Enable the service to start on boot: `:> sudo systemctl enable suspicious.service`

Start the service immediately: `:> sudo systemctl start suspicious.service`  

#### Status of the Service

confirm whether the service is active and running.: `:> sudo systemctl status suspicious.service`

### Examining the Running Service

Now investigate where evidence of the service exists.

#### 1) Reviewing the Directory

Installed services can typically be found in `/etc/systemd/system`

#### 2) Evidence in the Logs

Search the system log for service activity: `:> cat /var/log/syslog | grep suspicious`

#### 3) Examining `journalctl`

Command: `:> sudo journalctl -u suspicious`

`journalctl` provides detailed logs related to the service and may reveal execution attempts or errors made by the attacker.

### Persistence Questions

What is the default path that contains all the installed services in Linux?

Which suspicious service was found to be running on the host?

What process does this service point to?

Before getting this service stopped on 11th Sept, how many log entries were observed in the journalctl against this service?

## Footprints on Disk

Linux Incident Surface on the disk refers to areas of the filesystem that attackers may target and where traces of their activity may remain.  
From a forensic perspective, examining these areas is critical for understanding and investigating security incidents.  
By analyzing these locations, investigators can identify artifacts that support incident response and attribution.

### File System and Directories

Within the Linux filesystem, several files and directories contain sensitive information or record system activity.  
These locations are important during forensic investigations.

#### Configuration Files

The following configuration files are particularly important from a security perspective:

- `/etc/passwd` — Contains information about user accounts on the system.

- `/etc/shadow` — Stores hashed passwords for user accounts.

- `/etc/group` — Defines system groups and the users associated with them. Groups help manage permissions and organize users with similar privileges.

- `/etc/sudoers` — Configures `sudo` permissions and can be a target for privilege escalation attacks.

### Investigating Malicious Package

Attackers may create or install a malicious Debian package to execute code, establish persistence, or perform other malicious activities.  
In some cases, attackers may trick users into installing such packages.

To demonstrate this scenario, we simulate an attacker (Alice) creating and installing a malicious package before performing forensic investigation.

#### 1) Create Directory

Create a directory structure for the package.

`:> root@tryhackme:~# mkdir malicious-package`  

`:> root@tryhackme:/malicious-package# mkdir DEBIAN`

#### 2) Create Control File

Create a control file that defines metadata for the Debian package.  
Inside the `DEBIAN` directory, create a file named `control` and add the following content:


    Package: malicious-package
    Version: 1.0
    Section: base
    Priority: optional
    Architecture: all
    Maintainer: attacker@test.com
    Description: This is a malicious Package

This file describes the package and is required for building Debian packages.

#### 3) Add Malicious Script

Create a post-installation script that executes after the package installation.

Save the following script as `postinst` inside the `DEBIAN` directory.

```bash
#!/bin/bash
# Malicious post-installation script
# It will run this script after installation

# Print a suspicious message - for demonstration
echo "something suspicious"
```

#### 4) Make the Script Executable

Modify permissions to make the script executable.

`:> root@tryhackme:# chmod 755 malicious-package/DEBIAN/postinst`  

#### 5) Build the Package

Build the Debian package using the following command.

`:> root@tryhackme:# dpkg-deb --build malicious-package`  

This creates a `.deb` package file.

#### 6) Install the Package

Install the newly created package on the system.

`:> root@tryhackme: dpkg -i malicious-package.deb`

### Investigate the Suspicious Installed Package

After installing the package, investigate its traces on the system.

#### 1) Check the Installed Packages

List all installed packages: `:> dpkg -l` 

This command displays all packages installed on the system.  
Investigators can review the list to identify suspicious or unexpected packages.

If the package name is known, filtering can be applied to confirm its presence.

#### 2) Examining `dpkg.log`

Installation events are recorded in `/var/log/dpkg.log`.


    ubuntu@tryhackme:/home$ grep " install " /var/log/dpkg.log
    2024-06-13 06:47:05 install linux-image-5.15.0-1063-aws:amd64 <none> 5.15.0-1063.69~20.04.1
    2024-06-13 06:47:06 install linux-aws-5.15-headers-5.15.0-1063:all <none> 5.15.0-1063.69~20.04.1
    2024-06-13 06:47:09 install linux-headers-5.15.0-1063-aws:amd64 <none> 5.15.0-1063.69~20.04.1
    2024-06-24 19:17:39 install osquery:amd64 <none> 5.12.1-1.linux
    2024-06-26 05:54:38 install sysstat:amd64 <none> 12.2.0-2ubuntu0.3
    2024-06-26 14:32:05 install malicious-package:amd64 <none> 1.0


This log records package installation activity.  
Investigators can use it to identify when packages were installed and determine whether the installation is legitimate or suspicious.

### Footprints on Disk Questions

Create a suspicious Debian package on the disk by following the steps mentioned in the task.

- How many log entries are observed in the `dpkg.log` file associated with this installation activity?

- What package was installed on the system on the **17th of September, 2024**?

## Linux Logs

Logs in digital systems play an important role in understanding what occurred on a system.  
In Linux environments, logs are essential for monitoring system activities, detecting attacks, and identifying potential incident surfaces.

Logs record system events and activities that can help investigators identify and analyze security incidents.

### Syslog

- **Location:** `/var/log/syslog`
- This log file records **system-wide events**, warnings, and errors.
- It contains **general system messages**, including:
  - Kernel messages
  - System service activity
  - Application logs
- Useful for identifying issues affecting **system components or services**.

### Messages

- **Location:** `/var/log/messages`
- Similar to `syslog`, this file contains:
  - System messages
  - Kernel logs
- Commonly used to **diagnose system issues** and monitor system activity.
- Unusual entries related to hardware or kernel errors may indicate attempts to **tamper with system components**.

Example indicator:

- Repeated **kernel panic** messages may suggest a **denial-of-service (DoS) attack** targeting system stability.

### Authentication Logs

- **Location:** `/var/log/auth.log`
- Records **authentication activity**, including:
  - Successful login attempts
  - Failed login attempts
  - `sudo` usage
  - SSH login activity
- This log is important for detecting:
  - Unauthorized access attempts
  - Brute-force attacks

Example indicator:

- Multiple failed login attempts from an **unfamiliar IP address** or **unusual login times**.

### Examples of Events That May Indicate an Incident

The following events may be indicators of malicious or suspicious activity:

- Failed login attempts
- Successful login attempts occurring at unusual times  
  *(e.g., after business hours or weekends — context dependent)*
- Suspicious network communication
- System errors
- Creation of user accounts on sensitive servers
- Outbound traffic initiated from a web server

### Linux Log Questions

Examine the `auth.log` files.

- Which user attempted to connect with **SSH on 11th Sept 2024**?
- From which **IP address** was this failed SSH connection attempt made?


