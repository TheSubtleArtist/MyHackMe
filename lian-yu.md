# Lian Yu

> Converted from cybersecurity DOCX notes into a structured markdown outline and study reference.

### What is the Web Directory you found?

- 'dirb http://10.10.75.178 /usr/share/wordlists/dirb/common.txt -w'

- found "island" directory

- found a codeword: "vigilante" that was formatted in white to match the white background. Just had to select all

- the hint said the directory was four numbers

- created a list of 1-9999 and padded all numbers to three digits: "seq -w 9999 > numbers.txt "

- 'dirb http://10.10.75.178/island/ numbers.txt -w'

- directory is "2100"

- viewing the page code there is a clue about a ".ticket" extension

what is the file name you found?

- dirb http://10.10.75.178/island/2100 dirb/common.txt -X .ticket -w

- "green_arrow.ticket"

what is the FTP Password?

- use cipher identifier to find out the ticket is in base 58

- decode from base 58 with cyberchef

- username for FTP is "vigilante"

what is the file name with SSH password?

- several files

- changing directories reveals antoher user: "slade"

- "mget *" downloads all visible files but invisible files must be downloaded individually

- ".other_user" reveals "Jackal" "Kane" "Adeline" "Wintergreen" "Deathstroke" as another possbiel username

- appears to need some steganography

- ran strings against all the image and queens gambit had more information than is normal for a image

- binwalk, stegcracker, stegseek didn't work

- started stegcracker against aa.jpg and that revealed more files

- "shado"

user.txt

- ssh login with "slade" and "M3tahuman"

root.txt

- sudo -l:

User slade may run the following commands on LianYu:

(root) PASSWD: /usr/bin/pkexec

- command for pkexec: "sudo pkexec /bin/sh"
