# Race Conditions

Learn about race conditions and how they affect web application security.

## Multi-Threading

### Programs

set of instructions to achieve a specific task  


### Processes

a program in execution (job)  


***Program:*** The executable code related to the process
***Memory:*** Temporary data storage
***State:*** A process usually hops between different states. After it is in the `New` state, i.e., just created, it moves to the `Ready` state, i.e., ready to run once given CPU time. Once the CPU allocates time for it, it goes to the `Running` state. Furthermore, it can be in the `Waiting` state pending I/O or event completion. Once it exits, it moves to the `Terminated` state.  

![Process States](assets/race-101.svg)  

### Threads

a lightweight unit of execution. It shares various memory parts and instructions with the process.  

***Serial:*** One process is running; it serves one user after the other sequentially. New users are enqueued.
***Parallel:*** One process is running; it creates a thread to serve every new user. New users are only enqueued after the maximum number of running threads is reached.


## More Race Conditions

## Web Application Architecture

## Exploiting Race Conditions

## Detection and Mitigation

