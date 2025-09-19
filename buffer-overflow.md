# Buffer Overflows

Basic Buffer Overflows

## Tools

- radare2  

## Process Layout

### Context Switching  

- switching between processes
- current computer architecture allows multiple processes to be run concurrently  
- processes may appear to run at the same time  
- operating system keeps track of all the information in each process


### Memory Address Space (Virtual Memory Layout)  

============================================

High Memory (0xFFFFFFFF)  

┌─────────────────────────────────────┐
│              KERNEL SPACE           │ ← Reserved for OS
│         (Not accessible to          │
│           user programs)            │
├─────────────────────────────────────┤
│                                     │
│            USER STACK               │ ← Function calls, local vars
│               ▼ ▼ ▼                 │   (grows downward)
│         (grows downward)            │
│                                     │
│                 ...                 │
│                                     │
│         ┌─────────────────┐         │
│         │  Stack Frame N  │         │
│         ├─────────────────┤         │
│         │  Stack Frame 2  │         │
│         ├─────────────────┤         │
│         │  Stack Frame 1  │         │
│         └─────────────────┘         │
├─────────────────────────────────────┤
│                                     │
│        SHARED LIBRARY REGION        │ ← Dynamic libraries (.so/.dll)
│                                     │   - libc, OpenGL, etc.
│  ┌───────────────┐ ┌─────────────┐  │
│  │   libc.so     │ │  libm.so    │  │
│  │               │ │             │  │
│  └───────────────┘ └─────────────┘  │
│                                     │
├─────────────────────────────────────┤
│                                     │
│           RUN-TIME HEAP             │ ← Dynamic allocation
│               ▲ ▲ ▲                 │   (malloc, new, etc.)
│         (grows upward)              │   (grows upward)
│                                     │
│    ┌──────────┐ ┌────────────────┐  │
│    │ malloc() │ │   new object   │  │
│    │  block   │ │                │  │
│    └──────────┘ └────────────────┘  │
│                                     │
├─────────────────────────────────────┤
│                                     │
│         READ/WRITE DATA             │ ← Initialized global vars
│                                     │   Uninitialized data (BSS)
│  Global Variables:                  │
│  ┌─────────────┐ ┌───────────────┐  │
│  │ int x = 10; │ │ char buffer[] │  │
│  │ float pi;   │ │ static vars   │  │
│  └─────────────┘ └───────────────┘  │
│                                     │
├─────────────────────────────────────┤
│                                     │
│        READ-ONLY CODE/DATA          │ ← Program instructions
│                                     │   String literals
│  Program Code:                      │   Constants
│  ┌─────────────────────────────────┐│
│  │ main() {                        ││
│  │   printf("Hello World");        ││
│  │   return 0;                     ││
│  │ }                               ││
│  │                                 ││
│  │ String literals: "Hello World"  ││
│  │ Constants: const int MAX = 100  ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
Low Memory (0x00000000)

#### Memory Growth Directions 

========================
Stack:  ▼ ▼ ▼  (High → Low addresses)
Heap:   ▲ ▲ ▲  (Low → High addresses)

#### Memory Area Descriptions  

- User stack contains information required to run a program and functions. includes current program counter, saved registers. Followed by unused memory used as the stack grows(downwards)

- Shared library regions are used to either statically or dynamically link libraries that are used by the program

- The heap increases and decreases dynamically depending on whether a program dynamically assigns memory. There is an unassigned memory section the heap used as the heap grows (upward)

- The program code and data area stores the program executable and initialised variables.

#### Key Characteristics  

==================
• Stack: Fast, automatic cleanup, limited size
• Heap: Flexible size, manual management, slower
• Code: Execute permissions, shared between processes
• Data: Read/write permissions for variables
• Libraries: Loaded at runtime, shared memory  

## x86-64 Procedures

## Endianness  

## Overwriting Variables

## Overwriting Function Pointers

## Buffer Overflows Exercise 1  

## Buffer Overflows Exercise 2