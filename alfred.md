# Alfred

## Tools

***[Nishang](https://github.com/samratashok/nishang)*** is a framework and collection of scripts and payloads which enables usage of PowerShell for offensive security, penetration testing and red teaming. Nishang is useful during all phases of penetration testing.

## Initial Access

[Jenkins Documentation](https://www.jenkins.io/doc/book/installing/initial-settings/#networking-parameters) indicates the default port is 8080.

Shellhacks provide a quick understanding of [Jenkins Default Credentials](https://www.shellhacks.com/jenkins-default-password-username/). Since this instance is already running and the default username ('admin') is already known, it makes sense to attempt a brute force the login.

`:> hydra -s 8080 -l admin -P /usr/share/wordlists/SecLists/Passwords/xato-net-10-million-passwords-10000.txt 10.67.140.52 http-post-form '/j_acegi_security_check:j_username=^USER^&j_password=^PASS^&from=&pSubmit=Sign+in:Invalid username or password' -f -o /tmp/jenkins_login.txt`

Hydra identifies the ![weak password](/assets/jenkins-01.png).  


## Identify the exploitable feature

Jenkins has built-in capabilities for executing scripts.  

