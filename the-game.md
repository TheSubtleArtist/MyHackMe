# The Game

> Converted from cybersecurity DOCX notes into a structured markdown outline and study reference.

![The Game](assets/the-game-101.png)

## Downloaded Files

```bash
strings <file name> // Nothing
strings <file name> | grep _ // Nothing
strings <file name> grep -i // Nothing
unzip <file name> // reveals an executable and a MACOS directory
```

Enter the MACOS directory

```bash
strings ._Tetrix.exe // reveals some library calls, but not flags
```

Exit the MACOS directory

## Search the windows executable

```bash
strings Tetrix.exe | grep -i THM // found the flag THM{I_CAN_READ_IT_ALL}
```
