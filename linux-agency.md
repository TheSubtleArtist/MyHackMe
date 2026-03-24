# Linux Agency

## Linux Fundamentals

Agent 47, we are ICA, the Linux Agency. We will test your Linux Fundamentals. Let's see if you can pass all these challenges of basic Linux. The password of the next mission will be the flag of that mission. Example: mission1{1234567890} will be the password for the mission1 user.

### What is the mission1 flag?

`:> cd /`  

`:> grep -ir mission1{ > /home/agent47/mission1.txt`   

`:> cat mission1.txt` 

`:> exit`

### What is the mission2 flag?  

`:> su mission1`

`:> cd ~`

`:> ls`

`:> su mission2` 

`:> cd /home/mission2`  

`:> cat flag.txt`

`:> exit`

### What is the mission3 flag?  

`:> su mission3`  

`:> cd ../mission3`  

`:> find . -exec strings {} + | grep -i "mission"` : results  

`:> exit`

### What is the mission4 flag?

`:> su mission4`  

`:> cd ../mission4`

`:> ls -alh > directory`

`:> cat directory`

`:> cat flag/flag.txt`  

`:> exit`

### What is the mission5 flag?

`:> su mission5`  

`:> cd ../mission5`

`:> cat .flag.txt`  

`:> exit`

### What is the mission6 flag?

`:> su mission6`  

`:> cd ../mission6`  

`:> ls -alh > directory`  

explanation: directory names were hidden from the screen but showed when the listing was directed into a file  

`:> cat .flag/flag.txt`  

`:> exit`

### What is the mission7 flag?

`:> su mission7`  

`:> cd ../mission7`

`:> cat flag.txt`  

`:> exit`

### What is the mission8 flag? 

`:> su mission8`  

`:> cd ../mission8`

`:> find / -name flag* 2>/dev/null`  

`:> cat /flag.txt`  

`:> exit`

### What is the mission9 flag?

`:> su mission9`  

`:> cd ../mission9`  

`:> grep -i mission10 rockyou.txt`

`:> exit`

### What is the mission10 flag?

`:> su mission10`  

`:> cd ../mission10`

`:> find . / -name *flag* 2>/dev/null`  

`:> cat $(find . / -name *flag* 2>/dev/null)` 

`:> exit`  

### What is the mission11 flag?  

`:> su mission11`  

`:> ls -alhR > results`

`:> find . -type f -exec strings {} \;` : find all files in the current and subdirectories and execute the "strings" command on each file.  

`:> env`

`:> exit`  

### What is the mission12 flag?

`:> su mission12`  

`:> cat flag.txt` : no permissions to read, but am the owner... HA! funny.  

`:> chmod +r flag.txt` 

`:> cat flag.txt`  

`:> exit`

### What is the mission13 flag?

`:> su mission13`  

`:> cd ../mission13`

`:> cat flag.txt`  base64 encoded string

`:> base64 -d flag.txt` 
 
 `:> exit`

### What is the mission14 flag?

`:> su mission14`  

`:> cd ../mission14`  

`:> cat flag.txt`  : binary encoded string.

`:> awk '{for(i=1;i<=length($0);i+=8) printf "%c", strtonum("0b" substr($0,i,8))}' flag.txt`

`awk` : processes and analyzes text; best on structured text (csv, logs); `:> aws <optional pattern> { action} file`  

`{..}` : contains the program to be executed on the input text

`$0` : built-in representing the entire line of input; differentiated from $1, $2, .. $N representing columns.  

`for(i=1; i<=length($0); i+=8)` : open a for loop; set i=1, execute while the value of i is less than the length of the input $0, increment i by 8, effectively looping at the beginning of each binary encoded letter of the mission15 flag

`substr($0,i,8)` : extract a substring from $0, begining at i and containing 8 characters; resulting in a binary representation of a letter  

`0b substr($0,i,8)` : prepend '0b' to the extracted substring; tells awk to interpret the sub-string as binary format

`strtonum("0b" substr($0,i,8))` : string-to-number function; convert the substring to decimal value  

`printf "%c"` : print the `character` representation of the result of the strtonum function  

`:> exit`  

### What is the mission15 flag?

`:> su mission15`  

`:> cd ../mission15`  

`:> cat flag.txt`  : hexademical encoded string

`:> xxd -r -p flag.txt`  

`:> exit`  

### What is the mission16 flag?

`:> su mission16`  

`:> cd ../mission16`  

`:> file flag` : elf  

`:> strings flag` : nothing  

`:> chmod +x flag` : mission16 is the owner, but has limited rights  

`:> ./flag` : results  

`:>exit`  

### What is the mission17 flag?

`:> su mission17`  

`:> cd ../mission17`  

`:> file flag.java` : `flag.java: C source, ASCII text, with CRLF line terminators`  

`:> chmod +x flag.java`

`:> java flag.java` : failed

Convert to python:

```python
if __name__== '__main__':

    outputString=""
    encrypted_flag="`d~~dbc<5vk=4:;=;9445;o954nil>?=lo8k:4<:h5p"
    for each in encrypted_flag:
        outputString = outputString + chr(ord(each) ^13)
        print(outputString)
```

`:> exit`

### What is the mission19 flag?

`:> su mission18`  

`:> cd ../mission18`

`:> cat flag.rb`  

```ruby
def encryptDecrypt(string)
    key = ['K', 'C', 'Q']
    result = ""
    codepoints = string.each_codepoint.to_a
    codepoints.each_index do |i|
        result += (codepoints[i] ^ 'Z'.ord).chr
    end
    result
end

encrypted = encryptDecrypt("73))354kc!;j8<nk<ol8i;9lhh>bjb<m;nibohon8m'")
puts "#{encrypted}"
```

`:> ruby flag.rb`

`:> exit`  

### What is the mission20 flag?

`:> su mission19`  

`:> cd ../mission19`  

`:> ls -alh`  : flag.c  

`gcc flag.c -o flag`  

`:> ./flag`

`:> exit`

### What is the mission21 flag?

`:> su mission20`  

`:> cd ../mission20`

`:> ls -alh`  

`:> pythong3 flag.py`  

`:> exit`

### What is the mission22 flag?

`:> su mission21`

`:> cd ../mission21`  

`:> find / -user mission21 2>/dev/null > out`  

`:> find / -name *flag* 2>/dev/null > /home/mission21/out`

`:> cd /home/mission21`  

`:> cat .bashrc` : encoded flag found

`:> grep 'echo "' .bashrc | bash` : answer

`:> exit `  

### What is the mission23 flag?

`:> su mission22`  

Moves into a python environment.

```python
from os import system; system('bash')
```

`:> cd /home/mission22/`

`:> cat flag.txt`

`:> exit` 

`:> exit()`

### What is the mission24 flag?

`:> su mission24`

`:> cd ../mission24`

`:> cat message.txt`

`:> cat /etc/hosts`

`:> curl mission24.com`

`:> exit`

### What is the mission25 flag?

### What is the mission26 flag?

### What is the mission27 flag?

### What is the mission28 flag?

### What is the mission29 flag?

### What is the mission30 flag?

### What is viktor's Flag?

## Task 4 Privilege Escalation

Welcome to Privilege Escalation, 47. Glad you made it this far!!! Now, here are some special targets. Your Target is to teach these bad guys a lesson.

Good luck 47!!!!

Mission Active

Answer the questions below
su into viktor user using viktor's flag as password

### What is dalia's flag?

### What is silvio's flag?

### What is reza's flag?

### What is jordan's flag?

### What is ken's flag?

### What is sean's flag?

### What is penelope's flag?

### What is maya's flag?

### What is robert's Passphrase?

### What is user.txt?

### What is root.txt?