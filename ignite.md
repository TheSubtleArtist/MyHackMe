# IGNITE

## NMAP

`nmap -Pn -sV -O 10.201.126.242`  

PORT   STATE SERVICE VERSION  
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))

## Visit the Page  

A number of potentially useful instructions  

Default installation directory:  
![Instructions 01](assets/ignite-01.png)  

Software and location of the database:  
![Instructions 02](assets/ignite-02.png)  

Instructions which, if followed, make certain directories very useful for exploitation activities:  
![Instructions 03](assets/ignite-03.png)  

A place to look for hardcoded encryption keys; The potential for a directory above the web root that becomes vulnerable to traversal atacks.  
![Instructions 04](assets/ignite-04.png)  

Finally, default credentials  
![Instructions 05](assets/ignite-05.png)  

### Check robots.txt  

`http://10.201.126.242/robots.txt`  

![robots.txt](assets/ignite-06.png)  