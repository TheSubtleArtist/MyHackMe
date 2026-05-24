# Authentication Bypass

## OSINT

### Wayback URLs and Google Dorks

Digging into a web application's past can be as revealing as examining its current state. Archived pages, forgotten files, and indexed directories can expose old paths, administrative pages, or sensitive files that still exist on the live server.

#### Wayback URLs

The Internet Archive's Wayback Machine functions like a time machine for websites. It allows analysts to review older versions of a site and discover files or directories that are no longer linked from the current application but may still exist on the server.

![Wayback URLs](/assets/authentication-bypass-101.png)

For example, using TryHackMe as a target, older versions of the website can be reviewed from 2018 to the present.

![Wayback URLs](/assets/authentication-bypass-102.png)

To dump links saved in the Wayback Machine, use a tool such as `waybackurls`. The tool is hosted on GitHub and can be installed locally.

> Note: Installing this tool is outside the scope of the room. It is recommended to install it on your own VM rather than relying on the AttackBox.

```bash
# Install waybackurls
# Use the commands shown in the source screenshot for the lab environment.
```

![Wayback URLs](/assets/authentication-bypass-103.png)

#### Google Dorks

Google Dorks are specialized search queries used to discover indexed content that was not intended to be public. They can expose administrative panels, log files, password references, backup directories, and other sensitive resources.

Examples:

```text
site:example.com inurl:admin
filetype:log "password" site:example.com
intitle:"index of" "backup" site:example.com
```

Source: <https://tryhackme.com/room/enumerationbruteforce>

## Authentication Enumeration

Authentication enumeration is the process of analyzing authentication workflows to discover valid users, weak password policies, reset behavior, session flaws, and other operational details. The objective is to understand how the authentication system behaves under different inputs.

## Authentication Mechanism Flaws

Common authentication weaknesses include:

- Password-only authentication that enables repeated guessing of usernames and passwords.
- Weak credential requirements, such as short passwords, common passwords, or a limited character space.
- Weak session cookies, especially when token values are predictable.

## Password Policies

Password policies are useful for both offensive testing and defensive assessment. They reveal the expected complexity of application passwords and can shape an attacker's strategy.

A PHP password policy might use regular expressions to require symbols, numbers, and uppercase letters.

![Password Policies](/assets/authentication-bypass-104.png)

If an application returns the full regex requirement in an error message, it reveals the password policy to attackers. That information can be used to generate a password dictionary that satisfies the exact policy.

## Common Places to Enumerate

### Registration Pages

Registration pages can unintentionally confirm valid accounts.

- If the application immediately reports that an email address or username is already taken, it confirms the account exists.
- This feedback improves user experience but also supports account enumeration.
- Attackers can test likely usernames or email addresses and build a list of active users without direct database access.

### Password Reset Features

Password reset workflows can disclose account existence through inconsistent responses.

- Different messages for valid and invalid usernames help attackers verify identities.
- Even small response differences can be used to refine a list of valid users.
- This improves the effectiveness of later brute-force, credential stuffing, or phishing attempts.

### Verbose Errors

Verbose login errors reveal too much information when they distinguish between cases such as:

- `username not found`
- `incorrect password`

Although this helps legitimate users understand login failures, it gives attackers definitive clues about valid usernames.

### Data Breach Information

Credential data from previous breaches can be used to test credential reuse across platforms.

- A match may indicate reused usernames and passwords.
- A single breach can therefore affect multiple platforms.
- Password recycling increases the value of old breach data.

## Mitigations

Use layered authentication controls:

- Enforce a strong password policy.
- Apply automatic lockout or throttling after repeated login failures.
- Use multi-factor authentication.
- Avoid verbose account-existence messages.
- Normalize authentication and reset responses so attackers cannot distinguish valid users from invalid users.

## Example: Re-registration of Existing User

A common enumeration technique is to attempt to re-register a known or guessed username. If the application reports that the account already exists, the tester has confirmed a valid username.

## Username Enumeration

Username enumeration builds a list of valid usernames, often by abusing predictable website feedback.

Important indicators include messages such as:

```text
an account with this username already exists
```

Example `ffuf` command:

```bash
ffuf \
  -w /usr/share/wordlists/SecLists/Usernames/Names/names.txt \
  -X POST \
  -d "username=FUZZ&email=x&password=x&cpassword=x" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -u http://10.10.178.62/customers/signup \
  -mr "username already exists"
```

Command options:

- `-w`: Specifies the wordlist path.
- `-X`: Specifies the request method. `GET` is the default.
- `-d`: Specifies the data sent in the request body.
- `FUZZ`: Marks the value replaced by each username in the wordlist.
- `-H`: Adds request headers, such as `Content-Type`.
- `-u`: Specifies the target URL.
- `-mr`: Matches response text that confirms a valid username.

## Brute Force

After valid usernames are identified, attackers may test common passwords against those accounts.

Example `ffuf` command using two wordlists:

```bash
ffuf \
  -w valid_usernames.txt:W1,/usr/share/wordlists/SecLists/Passwords/Common-Credentials/10-million-password-list-top-100.txt:W2 \
  -X POST \
  -d "username=W1&password=W2" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -u http://10.10.178.62/customers/login \
  -fc 200
```

Operational meaning:

- `W1` supplies usernames.
- `W2` supplies passwords.
- `-fc 200` filters out responses with HTTP status code `200`, depending on how the target application signals failed logins.

## Password Reset Flow Vulnerabilities

Password reset functions are a common source of authentication bypass risk because they often need to verify identity, deliver a reset token, and update the password while preserving usability.

### Email-Based Reset

In an email-based reset flow:

- The application sends a reset link or token to the user's registered email address.
- The user follows the link and enters a new password, or the system generates one.
- The method depends heavily on the security of the user's email account and the secrecy of the reset link or token.

### Security Question-Based Reset

Security question resets require the user to answer preconfigured questions.

- Correct answers allow the reset process to continue.
- The method can be compromised if answers are guessable or discoverable from public personal information.
- PII from social media, breaches, or OSINT can weaken this approach.

### SMS-Based Reset

SMS reset flows send a reset code or link to the user's phone.

- The user enters the code into the web application.
- The model assumes the user's phone and phone number are secure.
- SMS reset can be vulnerable to SIM swapping or interception.

### Common Reset Weaknesses

- **Predictable tokens:** Sequential, short, or low-entropy tokens can be guessed or brute-forced.
- **Token expiration issues:** Tokens that remain valid too long increase the attack window.
- **Insufficient validation:** Weak identity checks can allow attackers to reset another user's password.
- **Information disclosure:** Reset messages that confirm valid accounts support enumeration.
- **Insecure transport:** Reset links and tokens sent over non-HTTPS connections can be intercepted.

## Exploiting Predictable Tokens

Tokens that are simple, predictable, or valid for too long are especially vulnerable to brute force. The lab application demonstrates a reset flow that uses a random three-digit PIN as the reset token.

![Exploiting Predictable Tokens](/assets/authentication-bypass-105.png)

Because the token uses only numeric values and has a small search space, it can be brute-forced.

To demonstrate, go to:

```text
http://enum.thm/labs/predictable_tokens/
```

![Exploiting Predictable Tokens](/assets/authentication-bypass-106.png)

On the password reset page, enter:

```text
admin@admin.com
```

Then click **Submit**.

![Exploiting Predictable Tokens](/assets/authentication-bypass-107.png)

The application responds with a success message.

![Exploiting Predictable Tokens](/assets/authentication-bypass-108.png)

For demonstration, the vulnerable application uses this reset link format:

```text
http://enum.thm/labs/predictable_tokens/reset_password.php?token=123
```

![Exploiting Predictable Tokens](/assets/authentication-bypass-109.png)

The token is a simple numeric value. In Burp Suite:

1. Navigate to the reset URL.
2. Capture the request.
3. Send the request to Intruder.
4. Highlight the token value.
5. Add the token value as the payload position.

![Exploiting Predictable Tokens](/assets/authentication-bypass-110.png)

Use Crunch to generate a list of numbers from `100` to `200`. This list becomes the brute-force dictionary.

```bash
# Generate candidate numeric tokens from 100 to 200.
# Use the exact Crunch command shown in the source screenshot for the lab.
```

![Exploiting Predictable Tokens](/assets/authentication-bypass-111.png)

Return to Intruder and configure the payload to use the generated file.

![Exploiting Predictable Tokens](/assets/authentication-bypass-112.png)

![Exploiting Predictable Tokens](/assets/authentication-bypass-113.png)

The attack may take time in Burp Suite Community Edition. A successful token is indicated by a response with a larger content length than the invalid-token responses.

![Exploiting Predictable Tokens](/assets/authentication-bypass-114.png)

After identifying the valid token, log in to the application with the new password.

![Exploiting Predictable Tokens](/assets/authentication-bypass-115.png)

> Lab note: Most real applications use six-digit codes or stronger tokens. The lab uses a smaller value to keep the exercise manageable in Burp Suite Community Edition.

## Exploiting Basic HTTP Authentication

Basic HTTP Authentication sends credentials in the `Authorization` header as a base64-encoded username and password pair. Base64 is not encryption; it is reversible encoding.

To demonstrate, go to:

```text
http://enum.thm/labs/basic_auth/
```

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-116.png)

Enter any username and password in the browser pop-up, then capture the Basic Auth request in Burp Suite.

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-117.png)

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-118.png)

Right-click the request and send it to Intruder.

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-119.png)

In Burp Intruder, go to the **Positions** tab and decode the base64-encoded string in the `Authorization` header.

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-120.png)

After decoding, highlight the decoded string and click **Add** in the top-right corner.

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-121.png)

Configure the payloads:

1. Go to the **Payloads** tab.
2. Set the payload type to **Simple list**.
3. Choose a wordlist, such as:

```text
/usr/share/wordlists/SecLists/Passwords/Common-Credentials/500-worst-passwords.txt
```

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-122.png)

Because the header must be base64 encoded, add payload-processing rules.

The first rule prepends the username to the password. For example, instead of testing only:

```text
123456
```

The payload becomes:

```text
admin:123456
```

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-123.png)

The second rule base64 encodes the combined `username:password` value.

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-124.png)

Remove the `=` character from payload encoding because base64 uses `=` for padding.

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-125.png)

Return to the **Positions** tab and start the attack.

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-126.png)

A response with status code `200` indicates a successful credential pair. Decode the successful base64 string to recover the working username and password.

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-127.png)

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-128.png)

Use the decoded credentials to log in to the application.

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-129.png)

![Exploiting Basic HTTP Authentication](/assets/authentication-bypass-130.png)

## Answer the Questions Below

The source document ends with this prompt but does not include the completed answers.

Source: <https://tryhackme.com/room/enumerationbruteforce>
