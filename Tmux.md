# TMUX

Terminal multiplexer:

- User runs multiple terminal sssions within a single terminal window
- Attach and detach specific sessions from the single terminal winodw
- Split the terminal into panes, without losing work in another pane
- create multiple windows, resembling tables, within a single session.

![Tmux Example](/images/tmux.png)

**[The PhoenixNap Tmux Cheatsheet](https://phoenixnap.com/kb/tmux-cheat-sheet)**

Key Points:

- Commands initiating interaction with a session group typically begin with "tmux"
- Commands interacting with windows and paynes typically begin with "CTRL+b" followed by another character
- Other interactions have various character combiantions. Refer to the cheatsheet for more comprehsneive lists.

## Sessions and Prefix

First, a standard terminal window:
![Plain Terminal](/images/terminal.png)

### Initiate a basic session

:>````tmux````  
![Basic Session](/images/basicSession.png)  
Key points:

- session name appears in lower left corner
- with no optional input, the default session prefix is `[0]`
- window names appear in the middle
- hostname, time, and date on the bottom right

### Rename a session

:>````CTRL + b````, then ````$```` (shift + 4)  
![Basic Session](/images/sessionRename.png)  
Input the name "new-name" and press enter  
![Basic Session Renamed](/images/sessionRenamed.png)

Key points:

- new session name appears in lower left corner

### Spawn a new detached (-d) session with a specific (-s) name

:>````tmux new -d -s session2````  
![New Detached Session2](/images/newDetachedSession.png)  
Key points:

- new session is created
- new session is detached, meaning not visible

### List active sessions

:>````tmux ls````  
![Session list](/images/sessionList.png)  
Key points:

- the currently attached session is marked '(attached)'

### Exit an attched sessions

>````CTRL + b````, then ````d````  
![Session Exit](/images/sessionExit.png)  
Verify by listing the sessions again
:>````tmux ls````  
![Session list](/images/sessionListAfterExit.png)

Key points:

- two active sessions are both detached
- user is unable to interact with either session

### Attach a session

>````tmux attach -t session2````  
![Session Attach](/images/sessionAttach.png)  
Verify by listing the sessions again  
:>````tmux ls````  
![Session list](/images/sessionListAfterAttached.png)  

Key points:

- name of attached session now appears in the lower left

### Delete a session by [session name]

:>````tmux session-kill -t new-name````  
![Session delete](/images/sessionNameKill.png)  

Key points:

- any unsaved work in a session will be deleted with the session-kill command

### Swap sessions but skip attach-detach overhead

First, generate several new sessions.  
:>````tmux new -d -s session3````  
:>````tmux new -d -s session4````  
:>````tmux new -d -s session5````  
:>````tmux new -d -s session6````  
:>````tmux ls````  
![Session switch](/images/sessionSwitchNewSessions.png)  

Second, list all sessions in a select mode
>````CTRL + b```` then ````s````  
![Session select](/images/sessionSelect.png)  
Use the up and down arrows to select a new session (session4) and press enter.  
![Session4 selected](/images/sessionSelect4.png)  

### Delete multiple sessions

Kill all (-a) sessions, except the specified session (-t)  
:>````tmux kill-session -a -t session3````  
:>````tmux ls````  
![Session switch](/images/sessionKillMultiple.png)  

Finally, switch to session3

Key points:

- If the active session was deleted, it will be exited
- if the session remaining was detached at the time, it remains detached

## Manipulating Windows

### Create a new windows

:>````CTRL + b```` then ````c````
![new window created](/images/createNewWindow.png)
Note: There are now two windows (0:bash and 1:bash)

### Rename the Current Window

:>````CTRL + b```` then ````,````  
![new window created](/images/windowRenaming.png)  
The window waits for the new name as input.  
![Window Renamed](/images/windowRenamed.png)  
Note: Window 1 was the most recently created and active window, and was renamed.  

### Next and Previous Window

Next Window :>````CTRL + b```` then ````n````  
Previous Window :>````CTRL + b```` then ````p````  
Switch to window 0:bash  
![Switch to 0:bash](/images/nextPreviousWindow.png)  

### Close Current Window

:>````CTRL + b```` then ````&````  
![Verify Close Current Window](/images/verifyCloseCurrentWindow.png)  
![Current Window Closed](/images/currentWindowClosed.png)  

### Spawn a new session and new window

:>````tmux new -s <session name> -n <window name>````  
:>````tmux new -s session7 -n window7````  
If you have an active session and window, you will receive the nested session warning.  
![Nested Window Warning](/images/nestedWarning.png)
Close the current window and start rom the bash command line
![Session and Window 7](/images/session7.png)

### Split Horizontally

:>````CTRL + b````, and ```` " ```` (double quote, not single quote)  
![Split Scrreen Horizontal](/images/splitScreenHorizontal.png)

There are two closely related and easily confused commands: resizing a window and switching windows
Switching Windows :>````CTRL + b```` THEN [Arrow Key]
Resizing Windows :>````CTRL + b```` AND [Arrow Key]

### Split Vertically

Starting from the top window  

![Vertical Split Starting Point](/images/vertSplitStart.png)  
:>````CTRL + b````, then ```` % ````
![Vertical Split Top](/images/vertSplitOne.png)  
Move to the bottom window and create a split
![Vertical Split Top](/images/vertSplitTwo.png)

## Manipulating Panes  

### Force Kill the Current Pane

When the current pane becomes unresponsive 
From the top left pane
:>````CTRL + b````, then ```` % ```` then ````y````
![Force Kill Pane 1](/images/forceKillPane1.png)
![Force Kill Pane 2](/images/forceKillPane2.png)

### Rotate the Currently Selected Pane Clockwise 1 Position

Add some text to the panes to start  
![Before Rotate](/images/rotate0.png)  
:>````CTRL + b````, then ```` } ````  
![Rotate 1](/images/rotate1.png)  
again :>````CTRL + b````, then ```` } ````  
![Rotate 2](/images/rotate2.png)  

### Rotate the Currently Selected Pane Counter-Clockwise 1 Position

:>````CTRL + b````, then ```` { ````  
![Rotate 3](/images/rotate3.png)  

### Manage Panes with Built-in Layouts

Uses the standard prefix follow by escape and a number [1..4]  
The change depends on the number of windows currently open, experinces will vary.  
:>````CTRL + b````, then ```` esc AND 1 ````  
![Layout 1](/images/layout1.png)
:>````CTRL + b````, then ```` esc AND 2 ````    
![Layout 2](/images/layout2.png)
:>````CTRL + b````, then ```` esc AND 3 ````    
![Layout 3](/images/layout3.png)
:>````CTRL + b````, then ```` esc AND 4 ````    
![Layout 4](/images/layout4.png)

To rotate through the built-in layouts:
:>````CTRL + b````, then ```` spacebar ````

### Detach a pane into its own window

When one pane contains too much data to be read  
![Four Pane Reset](/images/fourPaneLayout.png)

From pane "FOUR" execute the command:  

:>````CTRL + b````, then ```` ! ````  
![Four Pane Reset](/images/paneFourBreakout.png)  

rotate to the "next" or "previous" window  
![Four Pane Rotate](/images/breakoutRotate.png) 