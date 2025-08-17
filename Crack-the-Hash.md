# Crack The Hash

https://tryhackme.com/room/crackthehash

This is the ultimate in beginner rooms. Hash cracking is a great way to start because there are plenty of online resources to help. Cracking hashes is deterministic. There is really only one correct answer and it helps to have some immediate success when you are new to the craft.

In this room, each hash only needs one solution. Maybe we can create some success for people by exploring the multiple tools available to perform the cracking.

This is the list of tools we will highlight for each hash.. when possible.

**CrackStation**<br>
https://crackstation.net/
Crackstation is, fundamentally, a library of pre-cracked, unsalted hashes. A great go-to tool for the first step in any attempt to crack a hash.

**hash-identifier**<br>
https://gitlab.com/kalilinux/packages/hash-identifier<br>
A command line utility for identifying a user-supplied hash.

**Hashcat**<br>
https://hashcat.net/wiki/
An advanced password recovery tool. The user cannot be afraid to continually reference the wiki and learn about the intricacies of Hashcat. It's capabilities are limited only by the user's curiosity. The

**John The Ripper**<br>
https://www.openwall.com/john/<br>
Would be appropraitely names Jack of All Trades. John has the ability to perform password security auditing and recovery across operating systems as well as file types, including unix, macOS, Windows, web apps, groupware, zip files, and others. 

### Setup Notes ###<br>
Because of the potential level of repetition, each hash was placed in its own file in the Kali Linux environment. This facilitates some efficiencies when using the command line.<br>
![Screenshot of hash files inside the Kali Linux fs](/Screenshots/kaliHashfiles.png)<br>

## Task 1 ##
### Hash 1: 48bb6e862e54f2a795ffc4e541caed4d ###
#### Crackstation ####
![Hash1](/Screenshots/hash1.png)<br>
#### Hash Identifier ####
The simplest use of hash identifier is as any other linux command.<br>
:>````hash-identifier 48bb6e862e54f2a795ffc4e541caed4d````<br>
gives us the same results as Crackstation.<br>
![Hash1 with hash-identifier](/Screenshots/hash1-HI.png)<br>


### Hash 2: CBFDAC6008F9CAB4083784CBD1874F76618D2A97 
#### Crackstation ####
![Hash2](/Screenshots/hash2.png)<br>


### Hash-Identifier ###
Try piping the contents of the hash2 file into the hash-identifer command<br>
:>````cat hash2 | hash-identifier````<br>
This does not give a positive result.<br>
![Hash2 no piping](/Screenshots/hash2-HI1.png)<br>
Try again with the standard method<br>
:>````hash-identifier CBFDAC6008F9CAB4083784CBD1874F76618D2A97````<br>
![Hash2 with hash-identifer](/Screenshots/hash2-HI2.png)<br>

### Hash 3: 1C8BFE8F801D79745C4631D09FFF36C82AA37FC4CCE4FC946683D7B336B63032 ###
#### Crackstation ####
![Hash3](/Screenshots/hash3.png)<br>

### Hash-Identifier ###
Users can start the hash-identifer before supply a hash.
![Hash3 with hash-identifier](/Screenshots/hash3-HI.png)<br>

### Hash 4: $2y$12$Dwt1BZj6pcyc3Dy1FWZ5ieeUznr71EeNkJkUlypTsgbX1H68wsRom ###
#### Crackstation ####
![Hash4](/Screenshots/hash4.png)<br>
Crackstation has not seen this has before.

### Hash 5: 279412f945939ba78ce0758d3fd83daa ###
#### Crackstation ####
![Hash5](/Screenshots/hash5.png)<br>


## Task 2 ##

### Hash 6: F09EDCB1FCEFC6DFB23DC3505A882655FF77375ED8AA2D1C13F640FCCC2D0C85 ###
#### Crackstation ####
![Hash6](/Screenshots/hash6.png)<br>

### Hash 7: 1DFECA0C002AE40B8619ECF94819CC1B ###
#### Crackstation ####
![Hash7](/Screenshots/hash7.png)<br>

### Hash 8: $6$aReallyHardSalt$6WKUTqzq.UQQmrm0p/T7MPpMbGNnzXPMAXi4bJMl9be.cfi3/qxIf.hsGpS41BqMhSrHVXgMpdjS6xeKZAs02. ###
### Salt: aReallyHardSalt ###
#### Crackstation ####
![Hash8](/Screenshots/hash8.png)<br>

### Hash 9: e5d8870e5bdd26602cab8dbe07a942c8669e56d6 ###
### Salt: tryhackme ###
#### Crackstation ####
![Hash9](/Screenshots/hash9.png)<br>