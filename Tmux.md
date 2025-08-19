# TMUX
Terminal multiplexer:
- User runs multiple terminal sssions within a single terminal window
- Attach and detach specific sessions from the single terminal winodw
- Split the terminal into panes, without losing work in another pane
- create multiple windows, resembling tables, within a single session.

![Tmux Example](/images/tmux.png)<br>

**A Tmux Cheatsheet**
https://phoenixnap.com/kb/tmux-cheat-sheet

<ins>Key Points</ins>
- Commands initiating interaction with a session group typically begin with "tmux"
- Commands interacting with windows and paynes typically begin with "CTRL+b" followed by another character
- Other interactions have various character combiantions. Refer to the cheatsheet for more comprehsneive lists.

### Sessions and Prefix ###

First, a standard terminal window:<br>
![Plain Terminal](/images/terminal.png)<br>

<ins>Initiate a basic session</ins>

:>````tmux````<br>
![Basic Session](/images/basicSession.png)<br>
Key points:
- session name appears in lower left corner
- with no optional input, the default session prefix is `[0]`
- window names appear in the middle
- hostname, time, and date on the bottom right


<ins>Rename a session</ins>

:>````CTRL + b````, then ````$```` (shift + 4)<br>
![Basic Session](/images/sessionRename.png)<br>
Input the name "new-name" and press enter<br>
![Basic Session Renamed](/images/sessionRenamed.png)<br>

Key points:
- new session name appears in lower left corner

<ins>Spawn a new detached (-d) session with a specific (-s) name</ins>

:>````tmux new -d -s session2````<br>
![New Detached Session2](/images/newDetachedSession.png)<br>
Key points:
- new session is created
- new session is detached, meaning not visible

<ins>List active sessions</ins>

:>````tmux ls````<br>
![Session list](/images/sessionList.png)<br>
Key points:
- the currently attached session is marked '(attached)'

<ins>Exit an attched sessions</ins>

>````CTRL + b````, then ````d````<br>
![Session Exit](/images/sessionExit.png)<br>
Verify by listing the sessions again
:>````tmux ls````<br>
![Session list](/images/sessionListAfterExit.png)<br>

Key points:
- two active sessions are both detached
- user is unable to interact with either session

<ins>Attach a session</ins>

>````tmux attach -t session2````<br>
![Session Attach](/images/sessionAttach.png)<br>
Verify by listing the sessions again
:>````tmux ls````<br>
![Session list](/images/sessionListAfterAttached.png)<br>

Key points:
- name of attached session now appears in the lower left

<ins>Delete a session by [session name]</ins>

:>````tmux session-kill -t new-name````<br>
![Session delete](/images/sessionNameKill.png)<br>

Key points:
- any unsaved work in a session will be deleted with the session-kill command







