I will be keeping the overhead simple. This is a place where I will do my best to record what I do to improve my knowledge, skills, and abilities in the realm of cybersecurity. And likely some rants as well. Nobody will be looking at this and so it's a safe space... 

Confidentiality, Integrity, and Availability are the cornerstones of Cybersecurity. Unfortunately, every certification, every organziation, and every ego-maniacle gate-keepr in the industry thinks their definition is the aboslute pinnacle. They think this for some reason that is as yet completely mystical to me.  

The reality is that good definitions rarely give answers. Instead, these definitions should prompt questions on the part of the professional. In 1991, John McCumber, in his book "Assessing and managing security risk in IT systems : a structured methodology" gave us the most effective and useful definitions for the pillars. 

## Confidentiality ##
McCumber wrote:
> The primary consideration of confidentiality is not simply keeping information secret from everyone else; it is making it available only to those people who need it, when they need it, and under the appropriate circumstances. 

I would argue that McCumber gives birth to Zero-Trust in this definition. However, the failure of new professionals to look for the older magic means we failed to discover his ideas until twenty years later. McCumber doesn't seek to answer the question "What is confidentiality". Instead, he demands that professionals develop the necessary questions to determine if they have identified all the identies and attributes of a user, group, role, and service that would strongly indicate that a subjects request for access should be granted.

The use of specific words like "people", and "circumstances" may not have leant themselves to decomposing the idea of "people" and "circumstances" into users, groups, roles, services, and attributes. That might have been a bridge to far for "highly technical" types that rely on strict definitions and are often unable to make leaps of faith. Nevertheless, the foundation is there.

McCumber gives us the idea of multi-factor authentication as well as well as the extension into geolocation, geofencing, time, and a host of other attributes. For example, the IdAM engineer should consider putting certifications and expirations into their Active Directory or whichever solution they are using. Any system administrator requesting access to an administrator function should have their certification checks. If it's expired, they are denied access. This is a form of Attributed-based Access Control. 

We have had zero trust for some time, we just didn't recognize it.

## Integrity ##

Of integrity, McCumber wrote:
> how accurately and robustly the information reflects reality for a given application.

The question to be answered here is impossible to answer, but simple to state. To what degree must information presented represent reality, absent of perspective, to have integrity.

Philip K. Dick, the exceptionally gifted and prolific author lends his wisdom to this discussion identifing reality as
>that which, when you stop believing in it, doesn’t go away

No place can illustrate the ideas of integrity and reality more than the arena of Politics where two people can speak on the exact same topic use semantically and syntactically empty rhetoric, completely misrepresent reality and still incite the strongest of emotional reactions in tens of millions of people who have no idea what they are hearing other than "other guy bad". 

Integrity begs the receiver of information to think sufficiently critically to ask questions such as, 
- Does this information genuinly represent reality, or ground truth?
- What inconsistencies among the information might indicate decreased levels of integrity?
- Do I have sufficient understand of the topic to identify missing or incomplete information?
- To what degree is the source of information likely to have some bias?
- and oh so many more...

Whether people or data, integrity is the only true measure of quality.

## Availability ##

On this topic McCumber asserts that availability is > the ability of stored, transmitted, or processed information to be used for its intended purposes when required. 

In such a short statement, McCumber gave us incident response, backup, business continuity, and disaster recovery. 

#### The Shoulders of Giants ####

I submit that the evolution of technology and science certainly stands on the shoulders of giants. Those people whose blood, sweat, and tears led to hard-won advancements, including the ability to advance faster with much less blood, sweat, and tears. 

While it's necessary to memorize every possible defintion of the CIA triad simply to pass the certification exam of some organization with a self-interested need to beat its own definition of these central ideas into the mind of the burgeoning professional, don't ever think that looking back to the giants is not worth your time. You might find a great deal of future in the past.