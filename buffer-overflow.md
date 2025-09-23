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

```markdown
High Memory (0xFFFFFFFF) 

┌─────────────────────────────────────┐  
│             KERNEL SPACE            │ ← Reserved for OS  
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
```

#### Memory Growth Directions  

Stack:  ▼ ▼ ▼  (High → Low addresses)  
Heap:   ▲ ▲ ▲  (Low → High addresses)  

#### Memory Section Details  

##### User Stack  

- information required to run a program and functions
- current program counter, saved registers
- Contains function call frames
- Stores local variables and parameters
- Manages return addresses
- Fast allocation/deallocation
- Limited in size (typically 1-8 MB)  

##### Shared Library Region  

- used to either statically or dynamically link libraries  
- Houses dynamically linked libraries
- Shared between multiple processes
- Includes system libraries (libc, libm, etc.)
- Loaded at program startup or on-demand  

##### Run-Time Heap  

- increases and decreases dynamically  
- Used for dynamic memory allocation
- Managed by malloc(), free(), new, delete
- Flexible size but slower than stack
- Risk of memory leaks if not properly managed  

##### Read/Write Data  

- program executable and initialised variables.  
- Initialized data segment : Global variables with initial values
- BSS segment : Uninitialized global variables
- Static variables with function scope  

##### Read-Only Code/Data  

- Text segment : Compiled program instructions
- String literals and constants
- Shared between multiple instances of same program
- Protected from modification  

## x86-64 Procedures

### STACK MEMORY LAYOUT  

```markdown
┌─────────────────────────────────────────────────────────────────┐
│                    STACK MEMORY REGION                          │
│            (Contiguous Memory Addresses)                        │
└─────────────────────────────────────────────────────────────────┘  


Stack Bottom (High Memory Address)
┌─────────────────────────────────────┐
│                                     │
│           UNUSED STACK              │
│              SPACE                  │
│                                     │
│               ▼ ▼ ▼                 │ ← STACK GROWS DOWN
│         (toward lower addresses)    │
│                                     │
├─────────────────────────────────────┤ ← rsp (Stack Pointer)
│          TOP OF STACK               │   Points to TOP
│                                     │
└─────────────────────────────────────┘
Stack Top (Low Memory Address 0x0)
```

### PUSH OPERATION  

```markdown
BEFORE: push var (var = 42)
┌─────────────────┐
│   Unused Space  │
├─────────────────┤ ← rsp = 0x1020
│                 │
│                 │
│                 │
└─────────────────┘

STEP 1: Get value from 'var' memory location (value = 42)
STEP 2: Decrement rsp by 8 (rsp = 0x1020 - 8 = 0x1018)
STEP 3: Write value to new rsp location

AFTER: push var
┌─────────────────┐
│   Unused Space  │
├─────────────────┤
│                 │
├─────────────────┤ ← rsp = 0x1018 (DECREMENTED by 8)
│       42        │ ← NEW TOP OF STACK
│   (from var)    │
└─────────────────┘
```

### POP OPERATION  

```markdown
BEFORE: pop var (stack has value 42 on top)
┌─────────────────┐
│   Unused Space  │
├─────────────────┤
│                 │
├─────────────────┤ ← rsp = 0x1018
│       42        │ ← CURRENT TOP OF STACK
│                 │
└─────────────────┘

STEP 1: Read value at address given by rsp (reads 42)
STEP 2: Store value into var (var = 42)
STEP 3: Increment rsp by 8 (rsp = 0x1018 + 8 = 0x1020)

AFTER: pop var
┌─────────────────┐
│   Unused Space  │
├─────────────────┤ ← rsp = 0x1020 (INCREMENTED by 8)
│                 │ ← NEW TOP OF STACK
├─────────────────┤
│       42        │ ← DATA STILL HERE! (memory unchanged)
│                 │   Only rsp moved!
└─────────────────┘

*** IMPORTANT: Memory content doesn't change during POP! ***
*** Only the stack pointer (rsp) value changes! ***
```

### MULTIPLE FUNCTION STACK FRAMES

```markdown
Program: main() → function_a() → function_b()

Stack Bottom (High Memory)
┌───────────────────────────────────────┐
│           UNUSED SPACE                │
├───────────────────────────────────────┤
│                                       │
│        FUNCTION_B STACK FRAME         │ ← Currently executing
│  ┌─────────────────────────────────┐  │
│  │ Local Variables:                │  │
│  │   int local_b = 30              │  │
│  │ Function Arguments:             │  │
│  │   int param_b                   │  │
│  │ Return Address:                 │  │
│  │   → back to function_a()        │  │
│  │ Saved Registers                 │  │
│  └─────────────────────────────────┘  │ ← rsp points here
├───────────────────────────────────────┤
│        FUNCTION_A STACK FRAME         │
│  ┌─────────────────────────────────┐  │
│  │ Local Variables:                │  │
│  │   int local_a = 20              │  │
│  │   char buffer[100]              │  │
│  │ Function Arguments:             │  │
│  │   (none)                        │  │
│  │ Return Address:                 │  │
│  │   → back to main()              │  │
│  │ Saved Registers                 │  │
│  └─────────────────────────────────┘  │
├───────────────────────────────────────┤
│          MAIN STACK FRAME             │
│  ┌─────────────────────────────────┐  │
│  │ Local Variables:                │  │
│  │   int main_var = 10             │  │
│  │   int argc                      │  │
│  │ Function Arguments:             │  │
│  │   char** argv                   │  │
│  │ Return Address:                 │  │
│  │   → back to OS                  │  │
│  └─────────────────────────────────┘  │
└───────────────────────────────────────┘
Stack Top (Low Memory - toward 0x0)
```

### STACK FRAME LIFECYCLE

```markdown

FUNCTION CALL (Allocating New Frame):
┌─────────────────────────────────────┐
│ 1. PUSH arguments onto stack        │
│ 2. PUSH return address              │
│ 3. PUSH saved registers             │
│ 4. Allocate space for local vars    │
│    (rsp moves down)                 │
└─────────────────────────────────────┘
                  │
                  ▼
            NEW STACK FRAME
                  │
                  ▼
┌─────────────────────────────────────┐
│ Function executes...                │
│ - Uses local variables              │
│ - May call other functions          │
│ - May push/pop temporary values     │
└─────────────────────────────────────┘
                  │
                  ▼
FUNCTION RETURN (Deallocating Frame):
┌─────────────────────────────────────┐
│ 1. Clean up local variables         │
│    (rsp moves up)                   │
│ 2. POP saved registers              │
│ 3. POP return address               │
│ 4. Jump to return address           │
└─────────────────────────────────────┘
```

### DETAILED PUSH/POP MECHANICS

```markdown
RSP Movement during PUSH:
┌──────────┬──────────┬──────────────────────────┐
│ Before   │ After    │ Action                   │
├──────────┼──────────┼──────────────────────────┤
│ 0x1020   │ 0x1018   │ push var1 (rsp -= 8)     │
│ 0x1018   │ 0x1010   │ push var2 (rsp -= 8)     │
│ 0x1010   │ 0x1008   │ push var3 (rsp -= 8)     │
└──────────┴──────────┴──────────────────────────┘

RSP Movement during POP:
┌──────────┬──────────┬──────────────────────────┐
│ Before   │ After    │ Action                   │
├──────────┼──────────┼──────────────────────────┤
│ 0x1008   │ 0x1010   │ pop var3 (rsp += 8)      │
│ 0x1010   │ 0x1018   │ pop var2 (rsp += 8)      │
│ 0x1018   │ 0x1020   │ pop var1 (rsp += 8)      │
└──────────┴──────────┴──────────────────────────┘

Memory State After POP Operations:
┌─────────────────┐
│   Unused Space  │
├─────────────────┤ ← rsp = 0x1020 (back to original)
│      var1       │ ← DATA STILL EXISTS!
├─────────────────┤   But is now "above" stack top
│      var2       │ ← DATA STILL EXISTS!
├─────────────────┤   Will be overwritten by future pushes
│      var3       │ ← DATA STILL EXISTS!
└─────────────────┘
```

### STACK POINTER DIRECTIONS

```markdown
   ▲ Higher Memory Addresses (Stack Bottom)
   │
   │ POP: rsp += 8 ↑ (moves UP toward higher addresses)
   │
   │ PUSH: rsp -= 8 ↓ (moves DOWN toward lower addresses)
   │
   ▼ Lower Memory Addresses (Stack Top, toward 0x0)
```

Function Call Flow:  
main() calls function_a():  
  • Creates new stack frame  
  • rsp moves DOWN (lower addresses)  
  
function_a() returns to main():  
  • Destroys stack frame  
  • rsp moves UP (higher addresses)  

### Key Stack Concepts Summary

| Concept | Description | Memory Effect |
|---------|-------------|---------------|
| **Stack Frame** | Dedicated memory area for each function | Allocated on call, deallocated on return |
| **PUSH Operation** | Add data to stack top | rsp decreases by 8, data written |
| **POP Operation** | Remove data from stack top | rsp increases by 8, data read (but memory unchanged!) |
| **Stack Growth** | Always toward lower memory addresses | New data appears at progressively lower addresses |
| **Frame Management** | Each function gets its own frame | Automatic allocation/deallocation |

### Critical Notes

🔹 **Memory Persistence**: POP operations don't erase memory - they only move the stack pointer!  
🔹 **Stack Direction**: Stack grows DOWN (toward address 0x0) but we often draw it growing UP for visual clarity  
🔹 **Frame Isolation**: Each function's stack frame is separate, providing local variable isolation  
🔹 **Automatic Management**: Stack frames are automatically managed by the CPU and compiler  

This design makes function calls efficient and provides automatic memory management for local variables and function parameters.  

### Control Flow

Consider two functions:  

```markdown

int add(int a, int b){
   int new = a + b;
   return new;
}


int calc(int a, int b){
   int final = add(a, b);
   return final;
}

calc(4, 5)
```  

The following explanation assumes the current point of execution is inside the ```calc``` function. In this case ```calc``` is known as the ```caller function``` and ```add``` is known as the ```callee function```dotnetcli

The following presents the assembly code inside ```calc```dotnetcli

[sym.calc](assets/buffer-overflow-01-calc-function.png)  

```markdown

Stack Bottom (High Memory Address)
┌─────────────────────────────────────┐
│                                     │
│       Previous Stack Frame          │
│                                     │
├─────────────────────────────────────┤
│                                     │
│          CALC Stack Frame           │
│                                     │
└─────────────────────────────────────┘
Stack Top (Low Memory Address 0x0)
```

```add``` is invoked using the call operand (```callq sym.add```) in assembly.  
The call operand can take either a label as an argument(e.g. A function name), or it can take a memory address as an offset to the location of the start of the function in the form of call *value.  
Once the add function is invoked(and after it is completed), the program would need to know what point (memory address) to continue in the program.  
To do this, the computer pushes the address of the next instruction onto the stack, in this case the address of the instruction ```movl %eax, local_4h```.  
After this, the program would allocate a stack frame for the new function, change the current instruction pointer to the first instruction in the function, change the stack pointer(rsp) to the top of the stack, and change the frame pointer(rbp) to point to the start of the new frame.  

[sym.add](assets/buffer-overflow-02-add-function.png)

```markdown

Stack Bottom (High Memory Address)
┌─────────────────────────────────────┐
│                                     │
│       Previous Stack Frame          │
│                                     │
├─────────────────────────────────────┤
│                                     │
│          CALC Stack Frame           │
│                                     │
├─────────────────────────────────────┤
│                                     │
│         Return address (retq)       │
│ (remains part of calc stack frame)  │
├─────────────────────────────────────┤
│                                     │
│         add Stack Frame             │
│                                     │
└─────────────────────────────────────┘

Stack Top (Low Memory Address 0x0)
```

Once ```add``` finishes execution, it calls the return instruction(retq).  
This instruction will:

- pop the value of the return address of the stack (```popq %rbp```)
- deallocate the stack frame for the add function
- change the instruction pointer to the value of the return address (```0x562b77165631```)
- change the stack pointer(rsp) to the top of the stack, and
- change the frame pointer(rbp) to the stack frame of calc.

This returns to the previous state  

```markdown

Stack Bottom (High Memory Address)
┌─────────────────────────────────────┐
│                                     │
│       Previous Stack Frame          │
│                                     │
├─────────────────────────────────────┤
│                                     │
│          CALC Stack Frame           │
│                                     │
└─────────────────────────────────────┘
Stack Top (Low Memory Address 0x0)
```

### Data Transfer  

[sym.calc](assets/buffer-overflow-03-calc-function.png)  

The calc function takes 2 arguments(a and b).  
Upto 6 arguments for functions can be stored in the following registers:  

- rdi: 64-bit general purpose register; primarily serves as the first argument register  
- rsi: 64-bit general purpose register; primarily serves as the second argument register  
- rdx: 64-bit general purpose register; third argument register, also a data register for controlling size parameters, modes, and enviornment variables
- rcx: 64-bit general purpose register; fourth arguement register; loop counter register
- r8: 64-bit general purpose extended register; fifth arguement register
- r9: 64-bit general purpose extended register; sixth arguement register; last register for passing parameters/arguements  

Note: The use of seven or more arguements results in storing of those values on the functions stack frame
Arguments 7+: Stored on stack (slower access)  
[RSP + 0x08] → arg7  
[RSP + 0x10] → arg8  
[RSP + 0x18] → arg9  

Implications of 7+ arguements:  

- Complexity Increase : Stack frames become larger and more complex
- Performance Impact : Memory access overhead for stack arguments
- Exploitation Opportunity : Direct stack argument control via overflow
- Defense Challenges : Larger attack surface and complex memory layouts
- Payload Simplification : No gadgets needed for arguments 7+ (direct stack control)

Destination Indexes:  

- rax: 64-bit accumulator register; systcall register; stores results of arithmetic operations  (eax is the 32-bit version)

Caller's responsibility to preserve before function calls

- RAX, RCX, RDX, RSI, RDI, R8, R9, R10, R11

Callee's responsibility to preserve during function execution

- RBX, RBP, R12, R13, R14, R15, RSP
 
-
## ENDIANNESS

```markdown

ENDIANNESS COMPARISON
=====================

Memory Address:    0x1000  0x1001  0x1002  0x1003
                      |       |       |       |
                      v       v       v       v

BIG ENDIAN (Most Significant Byte First)
========================================
32-bit value: 0x12345678

    ┌─────┬─────┬─────┬─────┐
    │ 12  │ 34  │ 56  │ 78  │
    └─────┴─────┴─────┴─────┘
     MSB                 LSB
   (Most              (Least
 Significant)       Significant)

Human readable order: "Reads naturally left to right"


LITTLE ENDIAN (Least Significant Byte First)
============================================
32-bit value: 0x12345678

    ┌─────┬─────┬─────┬─────┐
    │ 78  │ 56  │ 34  │ 12  │
    └─────┴─────┴─────┴─────┘
     LSB                 MSB
   (Least             (Most
 Significant)       Significant)

Human readable order: "Bytes stored in reverse order"


MEMORY LAYOUT VISUALIZATION
===========================

Address:  │ Big Endian │ Little Endian │
─────────────────────────────────────────
0x1000    │     12     │      78       │
0x1001    │     34     │      56       │
0x1002    │     56     │      34       │
0x1003    │     78     │      12       │

KEY POINTS:
• x86/x64 architectures use Little Endian
• Network protocols typically use Big Endian
• Important for buffer overflow exploitation
• Affects how addresses are stored in memory
```

This visualization shows how the same 32-bit value (0x12345678) is stored differently in memory depending on the endianness of the system. This concept is crucial for buffer overflow training because:

1. **Return addresses** are stored according to the system's endianness
2. **Shellcode addresses** must be written in the correct byte order
3. **Payload construction** requires understanding how multi-byte values are arranged in memory


## Overwriting Variables

## Overwriting Function Pointers

## Buffer Overflows Exercise 1  

## Buffer Overflows Exercise 2