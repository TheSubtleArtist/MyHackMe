# Operating Systems: Introduction

## Invisible Manager

***operating system (OS)***  
core software  
coordinates everything happening on a computer  
sits between the user, applications, and the system’s physical hardware  
acts as the invisible manager keeping entire machine running as one unified system  

### System Privilege Layers

Different parts of the system operate at various permission levels  
Some components can communicate directly with the hardware, while regular applications run in a safer, restricted environment  

***Kernel space***  
kernel: directly manages hardware and system resources
privileged, locked-down core of the OS  
unrestricted access to the CPU, memory, storage, and all hardware components  

***User space***  
Where all standard applications run  
deliberately prevented from accessing hardware directly  
must make a system call and request that the kernel act on their behalf to access resources.

### Operating System Duties

| OS Responsibility        | What the OS Does                                                                                                                                         | Example                                                                                       |
|--------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| Process Management       | Creates, schedules, prioritizes, and terminates running programs. The OS decides how much CPU time each process gets, making multitasking feel seamless. | Opening multiple apps, like your browser, music player, and social media, without your computer freezing. |
| Memory Management        | Allocates RAM to processes, protects the app's memory from other processes, and reclaims memory when apps are closed. When RAM runs low, the OS uses virtual memory to keep your system stable.  | Opening multiple apps at once, the OS allocates RAM to each one and keeps them isolated so they don’t interfere or crash each other. |
| File System Management    | Organizes files into directories, handles naming, paths, permissions, metadata (name, size, type, timestamps).                                         | Creating a new folder, saving a photo, or setting a file to "read only".                     |
| User Management          | Handles multiple user accounts, authentication, and permissions to determine who can access what.                                                      | Logging in with your password and keeping your files inaccessible to other user accounts.     |
| Device Management        | Loads drivers and provides a universal interface (hardware abstraction layer), so apps can say “print this” or “play this sound.”                     | Plugging in a new mouse, printer, or external hard drive and having it work immediately.      |

### Operating System Security

***Authentication:*** Verifies who you are through login passwords and biometrics
***Permissions:*** Controls exactly what each user and app is allowed to read, write, or execute
***Isolation:*** Keeps every process in its own protected box (kernel/user space separation)
***System Protection:*** Safeguards critical system files and settings from unauthorized changes

