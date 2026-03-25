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

`:> exit`  

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

`:> su mission24`

`:> cd ../mission24`

`:> ./bribe`

```text
There is a guy who is smuggling flags
Bribe this guy to get the flag
Put some money in his pocket to get the flag

Words are not the price for your flag
Give Me money Man!!!
```

`:> strings bribe > out && cat out`  

```text
/lib64/ld-linux-x86-64.so.2
libc.so.6
strncmp                 <- strncmp is always worth investigating
puts
__stack_chk_fail
putchar
strlen
getenv                  <- trying to read and enviornment variable
system
__cxa_finalize
__libc_start_main
GLIBC_2.4
GLIBC_2.2.5
_ITM_deregisterTMCloneTable
__gmon_start__
_ITM_registerTMCloneTable
.*00*,-qH
v8ur!zpuH
pt{{r {tH
 tr%qqssH
pp!qq"zqH
AWAVI
AUATL
[]A\A]A^A_
pocket                  <- possible variable name
money                   <- possible variable name
Here ya go!!!
Don't tell police about the deal man ;)
init
There is a guy who is smuggling flags
Bribe this guy to get the flag
Put some money in his pocket to get the flag
export init=abc
Money
MONEY
Words are not the price for your flag
Give Me money Man!!!
;*3$"
GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0
crtstuff.c
deregister_tm_clones
__do_global_dtors_aux
completed.7698
__do_global_dtors_aux_fini_array_entry
frame_dummy
__frame_dummy_init_array_entry
bribe.c
__FRAME_END__
__init_array_end
_DYNAMIC
__init_array_start
__GNU_EH_FRAME_HDR
_GLOBAL_OFFSET_TABLE_
__libc_csu_fini
getenv@@GLIBC_2.2.5
putchar@@GLIBC_2.2.5
strncmp@@GLIBC_2.2.5
_ITM_deregisterTMCloneTable
puts@@GLIBC_2.2.5
_edata
strlen@@GLIBC_2.2.5
__stack_chk_fail@@GLIBC_2.4
system@@GLIBC_2.2.5
__libc_start_main@@GLIBC_2.2.5
__data_start
__gmon_start__
__dso_handle
_IO_stdin_used
__libc_csu_init
__bss_start
main
__TMC_END__
_ITM_registerTMCloneTable
__cxa_finalize@@GLIBC_2.2.5
.symtab
.strtab
.shstrtab
.interp
.note.ABI-tag
.note.gnu.build-id
.gnu.hash
.dynsym
.dynstr
.gnu.version
.gnu.version_r
.rela.dyn
.rela.plt
.init
.plt.got
.text
.fini
.rodata
.eh_frame_hdr
.eh_frame
.init_array
.fini_array
.dynamic
.data
.bss
.comment
```

`:> ltrace .bribe`

```text
getenv("pocket")                                                           = nil  <- trying to read and enviornment variable
getenv("init")                                                             = nil  <- trying to read and enviornment variable
puts("\n\nThere is a guy who is smugglin"...

There is a guy who is smuggling flags
)                              = 40
puts("Bribe this guy to get the flag"Bribe this guy to get the flag
)                                     = 31
puts("Put some money in his pocket to "...Put some money in his pocket to get the flag
)                                = 45
system("export init=abc" <no return ...>
--- SIGCHLD (Child exited) ---
<... system resumed> )                                                     = 0
puts("\nWords are not the price for you"...
Words are not the price for your flag
)                               = 39
puts("Give Me money Man!!!\n"Give Me money Man!!!

)                                             = 22
+++ exited (status 0) +++
```

`:> $pocket` : no valuable response  

```bash
:> export pocket=1000
:> ltrace ./bribe
```

result:

```text
getenv("pocket")                                                           = "1000" < get the enviornmenet variable
strncmp("1000", "money", 5)                                                = -60    < perform a string compare
getenv("init")                                                             = "1"
puts("\nWords are not the price for you"...
Words are not the price for your flag
)                               = 39
puts("Give Me money Man!!!\n"Give Me money Man!!!

)                                             = 22
+++ exited (status 0) +++
```

`:> export pocket=money && ./bribe` : solution

`:> exit`  

### What is the mission26 flag?

`:> su mission25`  

`:> cd ../mission25`  

`:> ls -alh`  

```text
bash: ls: No such file or directory  
```

`:> cat /home/mission25/.bashrc`  

```text
bash: cat: No such file or directory  
```

`:> compgen -c` : list available commands`

`:> cd /home/mission25`  

`:> echo *` : less pretty method for listing directory contents  

`:> less flag.txt`  

`:> exit`

### What is the mission27 flag?

`:> su mission26`  

`:> cd ../mission26 && ls -alh`  

```text
total 100K
drwxr-x---  2 mission26 mission26 4.0K Jan 12  2021 .
drwxr-xr-x 45 root      root      4.0K Jan 12  2021 ..
lrwxrwxrwx  1 mission26 mission26    9 Jan 12  2021 .bash_history -> /dev/null
-rw-r--r--  1 mission26 mission26 3.7K Jan 12  2021 .bashrc
-r--------  1 mission26 mission26  84K Jan 12  2021 flag.jpg
-rw-r--r--  1 mission26 mission26  807 Jan 12  2021 .profile
```

`:> strings flag.jpg | grep mission27`

`:> exit`

-mission27{444d29b932124a48e7dddc0595788f4d}

### What is the mission28 flag?

`:> cd ../mission27 && ls -alh`  

```text
total 20K
drwxr-x---  2 mission27 mission27 4.0K Jan 12  2021 .
drwxr-xr-x 45 root      root      4.0K Jan 12  2021 ..
lrwxrwxrwx  1 mission27 mission27    9 Jan 12  2021 .bash_history -> /dev/null
-rw-r--r--  1 mission27 mission27 3.7K Jan 12  2021 .bashrc
-rw-r--r--  1 mission27 mission27  136 Jan 12  2021 flag.mp3.mp4.exe.elf.tar.php.ipynb.py.rb.html.css.zip.gz.jpg.png.gz
-rw-r--r--  1 mission27 mission27  807 Jan 12  2021 .profile
mission27@linuxagency:~$ 
```  

`:> file flag.mp3.mp4.exe.elf.tar.php.ipynb.py.rb.html.css.zip.gz.jpg.png.gz`

```text
flag.mp3.mp4.exe.elf.tar.php.ipynb.py.rb.html.css.zip.gz.jpg.png.gz: 
gzip compressed data, 
was "flag.mp3.mp4.exe.elf.tar.php.ipynb.py.rb.html.css.zip.gz.jpg.png", 
last modified: Mon Jan 11 06:42:10 2021, from Unix
```

`:> gunzip flag.mp3.mp4.exe.elf.tar.php.ipynb.py.rb.html.css.zip.gz.jpg.png.gz && ls`

`:> file flag.mp3.mp4.exe.elf.tar.php.ipynb.py.rb.html.css.zip.gz.jpg.png`  

```text
flag.mp3.mp4.exe.elf.tar.php.ipynb.py.rb.html.css.zip.gz.jpg.png: GIF image data, version 87a, 27914 x 29545
```

`:> strings flag.mp3.mp4.exe.elf.tar.php.ipynb.py.rb.html.css.zip.gz.jpg.png`  

`:> exit`

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
