# The DREAD Framework

Highly qualitative Model for risk assessment 
Developed by Microsoft
Used to evaluate and Prioritize security threats and vulnerabilities

## Defined

### (D)amage

Identifying the potential harm resulting from successful exploitation of a vulanerability
Data loss, system downtime, reputaional damage, etc..

## (R)eproducability

Eas with which and attacker can successfully recreat the exploitation of a vulaneraiblity
Higher reproducability socre sugges a vulnerability is easier to abuse, increasing the risk

### (E)xploitability

Difficulty involved in exploiting the vulnerability
Factors: requies technical skills, availability of tools or expllits, amount of time required to successfully exploit

### (A)ffected Users 

Number or portion of users impacted by a successful exploitation

### (D)iscoverability 

Ease with which an attacker an find and identify the vulenrability
Is it publicly known?
Is it publicly reachable or in a regulated environemnt?


## Analysis

### DREAD Threat Modeling Framework Rating Guide (0–10 Scale)

|     | **2.5 (Low)**                  | **5.0 (Medium-Low)**             | **7.5 (Medium-High)**              | **10 (High)**                       |
|-----|--------------------------------|----------------------------------|------------------------------------|-------------------------------------|
| **D**amage Potential<br>How severe is the potential impact? | Minor data leak or temporary disruption | Some data exposure or moderate downtime | Significant data loss or major service disruption | Complete system compromise or massive data breach |
| **R**eproducibility<br>How easily can the attack be repeated? | Difficult; requires rare conditions | Possible with effort or specific tools | Reliable with standard tools | Always works; no special conditions needed |
| **E**xploitability<br>How much effort/skill is required? | Expert skill and custom tools needed | Intermediate skill; some tools available | Basic skill; public exploits exist | Novice; fully automated or trivial |
| **A**ffected Users<br>What portion of users/systems are impacted? | Very few (e.g., <1%) | Some users (e.g., 1–25%) | Many users (e.g., 25–75%) | All users or entire system |
| **D**iscoverability<br>How likely is the vulnerability to be found? | Practically obscure; deep inspection required | Difficult to find; needs targeted testing | Easy with standard scans/tools | Obvious; publicly known or easy to spot |

*Overall risk can be calculated as the average or sum of scores (higher = greater priority for mitigation).*