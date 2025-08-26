# [Crack The Hash](https://tryhackme.com/room/crackthehash)

This is the ultimate in beginner rooms. Hash cracking is a great way to start because there are plenty of online resources to help. Cracking hashes is deterministic. There is really only one correct answer and it helps to have some immediate success when you are new to the craft.

In this room, each hash only needs one solution. Maybe we can create some success for people by exploring the multiple tools available to perform the cracking.

This is the list of tools we will highlight for each hash.. when possible.

**[CrackStation]**  
[Crackstation](https://crackstation.net/)  is, fundamentally, a library of pre-cracked, unsalted hashes. A great go-to tool for the first step in any attempt to crack a hash.

**Hash-Identifier**  
[Hash-Identifier](https://gitlab.com/kalilinux/packages/hash-identifier) is a command line utility for identifying a user-supplied hash. There will be much more on this near the end.

**Hashcat**  
[Hashcat](https://hashcat.net/wiki/) is an advanced password recovery tool. The user cannot be afraid to continually reference the wiki and learn about the intricacies of Hashcat. It's capabilities are limited only by the user's curiosity. At the beginning level we are concerned with two hashcat options: Core Attack Mode (-a) and Hash Mode (-m). [Example hashes](https://hashcat.net/wiki/doku.php?id=example_hashes) show the hash-modes, especially if no other source has identified the hash. Visual identification might be the final resource.  
The basic hashcat command looks like:  
:> ````hashcat -a <attack-mode> -m <hash-mode> <hash> <path-to-wordlist>````  
In the event there is more than than one hash of the same type, they may each be placed on separate lines in a file.
![File With Multiple Hashes](/assets/hashcat01.png)  
The basic command changes only slightly:  
:> ````hashcat -a <attack-mode> -m <hash-mode> <path-to-file> <path-to-wordlist>````  

**John The Ripper**  

[John the Ripper](https://www.openwall.com/john/) is an open-source password auditing tool with a list of features, from their website  

- fully configurable for your particular needs
- available for several different platforms

**The Wordlist**
There are innumerable sources of wordlists. Kali Linux comes with wordlists pre-installed in /usr/share/wordlists/. This includes the most commonly used source 'rockyou.txt' which requires expansion prior to first used. In addition, very active Daniel Miessler maintains a considerable number of enriched security lists on Github [SecLists](https://github.com/danielmiessler/SecLists)

## Setup Notes  

Because of the potential level of repetition, each hash was placed in its own file in the Kali Linux environment. This facilitates some efficiencies when using the command line.  
![Screenshot of hash files inside the Kali Linux fs](/assets/kaliHashfiles.png) 
NOTE: There can be no invisible characters in the file. If there are, Hashcat will quit and indicate a "Token Length" error. 

## Task 1

### Hash 1: 48bb6e862e54f2a795ffc4e541caed4d

#### Crackstation

![Hash1](/Screenshots/hash1.png)

#### Hash Identifier

The simplest use of hash identifier is as any other linux command.  
:>````hash-identifier 48bb6e862e54f2a795ffc4e541caed4d````  
gives us the same results as Crackstation.  
![Hash1 with hash-identifier](/Screenshots/hash1-HI.png)  
#### Hashcat

The command:
:>````hashcat -m 0 -a 0 hash1 /usr/share/wordlists/rockyou.txt````
The result:
![Hash1 with Hashcat](/Screenshots/hash1-HC.png)

### Hash 2: CBFDAC6008F9CAB4083784CBD1874F76618D2A97  

#### Crackstation

![Hash2](/Screenshots/hash2.png)

### Hash-Identifier

Try piping the contents of the hash2 file into the hash-identifer command
:>````cat hash2 | hash-identifier````
This does not give a positive result.
![Hash2 no piping](/Screenshots/hash2-HI1.png)
Try again with the standard method
:>````hash-identifier CBFDAC6008F9CAB4083784CBD1874F76618D2A97````
![Hash2 with hash-identifer](/Screenshots/hash2-HI2.png)  

#### Hashcat

The command changes the hash-mode to 100, indicating the sha-1 hash:
:>````hashcat -m 100 -a 0 hash2 /usr/share/wordlists/rockyou.txt````
The result:
![Hash2 with Hashcat](/Screenshots/hash2-HC.png)

### Hash 3: 1C8BFE8F801D79745C4631D09FFF36C82AA37FC4CCE4FC946683D7B336B63032

#### Crackstation

![Hash3](/Screenshots/hash3.png)

### Hash-Identifier

Users can start the hash-identifer before supply a hash.
If there are multple hashes, hash-identifer continuse in an endless loop until it receives a keyboard interrupt.
![Hash3 with hash-identifier](/Screenshots/hash3-HI.png)
Hash-Identifier provides the same result as Crackstation.

#### Hashcat

This one introduces a bit of complexity. Secure Hash Algorithms (SHA) is a family of hash algorithms. The SHA2 family includes 224, 256, 512, and some variations. When searching for the correct hash mode, the user must observe the formats of the various hashes that appear on the hashcat example pages. In this case, the correct mode is not sha-256, but sha2-256.
:>````hashcat -m 1400 -a 0 hash3 /usr/share/wordlists/rockyou.txt````
The result:
![Hash3 with Hashcat](/Screenshots/hash3-HC.png)


### Hash 4: $2y$12$Dwt1BZj6pcyc3Dy1FWZ5ieeUznr71EeNkJkUlypTsgbX1H68wsRom

#### Crackstation

![Hash4](/Screenshots/hash4.png)
Crackstation has not seen this has before.

### Hash-Identifier

![Hash4 with hash-identifier](/Screenshots/hash4-HI.png)
Also unidentifiable by hash-identifier.

#### Hashcat

Here is the first one which is unidentified by both Crackstation and Hash-Identifier. We can resort to visual matching on the Hashcat exmaples page. The "$" is a separator. Performing a search for "$2y" yields no results. But if we understand this is still an entry level room, then the hash mode should still have a fairly small number, searching for "$2*" indicates bcrypt.
Bcrypt begins to get tougher. For this iteration, I chose to perform the operation on my Windows host, rather than the Kali VM. This lets me allow greater gpu and cpu allocation. Nothing realy changes. I simply put the hash into a file called hashes.txt and still use rockyou.txt, both located in the hashcat folder on the C drive. The command changes only slightly:
:>````.\hashcat.exe -m 3200 -a 0 -w 4 -D 1,2 hashes.txt rockyou.txt````
The result:
![Hash4 with Hashcat](/Screenshots/hash4-HC.png)

### Hash 5: 279412f945939ba78ce0758d3fd83daa

#### Crackstation

![Hash5](/Screenshots/hash5.png)

### Hash-Identifier
![Hash5 with hash-identifier](/Screenshots/hash5-HI.png)

## Task 2

### Hash 6: F09EDCB1FCEFC6DFB23DC3505A882655FF77375ED8AA2D1C13F640FCCC2D0C85
#### Crackstation
![Hash6](/Screenshots/hash6.png)

### Hash-Identifier
![Hash6 with hash-identifier](/Screenshots/hash6-HI.png)

### Hash 7: 1DFECA0C002AE40B8619ECF94819CC1B
#### Crackstation
![Hash7](/Screenshots/hash7.png)

### Hash-Identifier ###
![Hash7 with hash-identifier](/Screenshots/hash7-HI.png)

### Hash 8: $6$aReallyHardSalt$6WKUTqzq.UQQmrm0p/T7MPpMbGNnzXPMAXi4bJMl9be.cfi3/qxIf.hsGpS41BqMhSrHVXgMpdjS6xeKZAs02.
### Salt: aReallyHardSalt
#### Crackstation
![Hash8](/Screenshots/hash8.png)

### Hash-Identifier
As the documentation indicates, hash-identifier works only with unsalted hashes.

### Hash 9: e5d8870e5bdd26602cab8dbe07a942c8669e56d6
### Salt: tryhackme
#### Crackstation
![Hash9](/Screenshots/hash9.png)