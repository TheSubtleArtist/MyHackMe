# Anonforce
boot2root machine for FIT and bsides guatemala CTF

10.201.110.177



`:> nmap 10.201.110.177`

 ![nmap 1](assets/anonforce-01-nmap-01.png)  

 Perform anonymous login  

 ![ftp 1](assets/anonforce-02-ftp-01.png) 

 Attempt to download the file via the ftp but fails.

 `get melodias`

![ftp 1](assets/anonforce-03-ftp-02.png)

Exit out the command line and try combining the wget and ftp protocols  

`:> wget -m --ftp-user=anonymous --ftp-password='' ftp://10.201.110.177/home/melodias`  

![wget 1](assets/anonforce-04-wget-01.png)

Downloaded nine files

![wget 2](assets/anonforce-05-wget-02.png)

Move into the downloaded directories and simultaneously realize why the ftp commands didn't work correctly :shrug:

![User.txt](assets/anonforce-06-user-txt-.png)
