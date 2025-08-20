# TMUX

Terminal multiplexer:

- User runs multiple terminal sssions within a single terminal window
- Attach and detach specific sessions from the single terminal winodw
- Split the terminal into panes, without losing work in another pane
- create multiple windows, resembling tables, within a single session.

![Tmux Example](/images/tmux.png)

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

<ins>Swap sessions but skip attach-detach overhead</ins>

First, generate several new sessions.
:>````tmux new -d -s session3````<br>
:>````tmux new -d -s session4````<br>
:>````tmux new -d -s session5````<br>
:>````tmux new -d -s session6````<br>
:>````tmux ls````<br>
![Session switch](/images/sessionSwitchNewSessions.png)<br>

Second, list all sessions in a select mode
>````CTRL + b```` then ````s````<br>
![Session select](/images/sessionSelect.png)<br>
Use the up and down arrows to select a new session (session4) and press enter.
![Session4 selected](/images/sessionSelect4.png)<br>

<ins>Delete multiple sessions</ins>

:>````tmux session-kill -a -t session3````<br>
- delete all (-a) sessions
- keep (-t) session3
:>````tmux ls````<br>
![Session switch](/images/sessionKillMultiple.png)<br>

Key points:
- If the active session was deleted, it will be exited
- if the session remaining was detached at the time, it remains detached



### Splitting Windows ###

<ins>Create a new windows</ins>

:>````CTRL + b```` then ````c````<br>
![new window created](/images/createNewWindow.png)<br>
Note: There are now two windows (0:bash and 1:bash)

<ins>Rename the Current Window</ins>

:>````CTRL + b```` then ````,````<br>
![new window created](/images/windowRenaming.png)<br>
The window waits for the new name as input.<br>
![Window Renamed](/images/windowRenamed.png)<br>
Note: Window 1 was the most recently created and active window, and was renamed.




<ins>Spawn a new session and new window</ins>

:>````tmux new -s <session name> -n <window name> ```` <br><br>
:>````tmux new -s session07 -n window07 ```` <br>
![Session and Window 7](/images/session07.png)<br>



![Verify Close Current Window](/images/closeCurrentWindow.png)<br>


 
<ins>Split Horizontally</ins>

:>````CTRL + b````, and ```` " ```` (double quote, not single quote) <br>
![Split Scrreen Horizontal](/images/splitScreenHorizontal.png)<br>

There are two closely related and easily confused commands: resizing a window and switching windows<br>
Switching Windows :>````CTRL + b```` THEN [Arrow Key] <br>
Resizing Windows :>````CTRL + b```` AND [Arrow Key] <br>

<ins>Close Current Windows</ins>

:>````CTRL + b````, then ```` & ```` <br>
Note that tmux verifies the decision
![Verify Close Current Window](/images/closeCurrentWindow.png)<br>
The user verifies the decision<br>
![Current Window Closed](/images/closeCurrentWindowVerified.png)<br>


<ins>Spawn a new session and new window</ins>

:>````tmux new -s <session name> -n <window name> ```` <br>

![Verify Close Current Window](/images/closeCurrentWindow.png)<br>








