# Hydra

## introduction

Parallelized Network Login Cracker
[Official Repository](https://github.com/vanhauser-thc/thc-hydra)
[Kali Linux instructions](https://en.kali.tools/?p=220)

`:> hydra -l <username> -P <wordlist of passwords> -t  <#> <server ip or hostname> <service>`  

Option 	Description
-l 	specifies the (SSH) username for login
-P 	indicates a list of passwords
-t 	sets the number of threads to spawn  

## SSH

`:> hydra -L <list.txt> -p <password> <target machine> -t 5 ssh`  

where  
 
-L : file containing a list of words to use as usernames  
-p : is a single password that will be attempted for each username  
-t : will set up five threads

## Post Web Form  

Attacker must know which type of request is needed. Commonly GET or POST. Also commonly identifieable in the network tab of the developer tools.

`:> sudo hydra -l <username> -P <password> <MACHINE IP http-post-form "<path to form>:<login_credentials>:<invalid_response>"`  

where  

`-l` is the single username  
`-P` is the list of potential passwords  
`http-post-form` is the type of request required by the form  
`<path>` is the login page URL  
`<login_credentials>` represents the field names for the username and password and placeholders for the specific usernames and passwords (e.g. `username=^USER^&password=^PASS^`)  
`<invalid response>` part of the response to return when the login fails  
`-V` sets verbose output for every attempt.  

`:> hydra -l <username> -P <wordlist> <MACHINE IP> http-post-form "/:username=^USER^&password=^PASS^:F=incorrect" -V`  

where

`/` indicates the login is the landing page  
`username` is the form field where the username is entered
`^USER^` represents the specific username value that will be entered into the field 'username'  
`password` is the form field where the password is entered  
`^PASS^` represents the specific password value that will be entered into the field 'password'  
`F=incorrect` is a string that appears in teh server reply when the login fails  

## Mitigations  

- Password Policy: Enforces minimum complexity constraints on the passwords set by the user.
- Account Lockout: Locks the account after a certain number of failed attempts.
- Throttling Authentication Attempts: Delays the response to a login attempt. A couple of seconds of delay is tolerable for someone who knows the password, but they can severely hinder automated tools.
- Using CAPTCHA: Requires solving a question difficult for machines. It works well if the login page is via a graphical user interface (GUI). (Note that CAPTCHA stands for Completely Automated Public Turing test to tell Computers and Humans Apart.)
- Requiring the use of a public certificate for authentication. This approach works well with SSH, for instance.
- Two-Factor Authentication: Ask the user to provide a code available via other means, such as email, smartphone app or SMS.
- There are many other approaches that are more sophisticated or might require some established knowledge about the user, such as IP-based geolocation.