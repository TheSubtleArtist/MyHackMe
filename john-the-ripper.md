# John the Ripper

## Basic Syntax

John the Ripper uses a target file containing one or more hashes and attempts to recover the original password using a selected cracking mode, wordlist, and hash format.

```bash
john [options] <path-to-file>
```

Common command patterns:

```bash
john --wordlist=<path-to-wordlist> <path-to-file>
john --format=<hash-type> --wordlist=<path-to-wordlist> <path-to-file>
john --format=raw-<hash-type> --wordlist=<path-to-wordlist> <path-to-file>
```

Operational notes:

- Use a wordlist when you want John to test known or likely passwords against a hash.
- Use `--format` when John does not automatically identify the hash correctly or when multiple formats are possible.
- Some common hash formats require the `raw-` prefix.

## Hash Identification

Hash identification helps determine the correct `--format` value before cracking.

Useful reference and setup:

```bash
wget https://gitlab.com/kalilinux/packages/hash-identifier/-/raw/kali/master/hash-id.py
```

Useful John command:

```bash
john --list-formats
```

Study notes:

- `hash-identifier` can help identify the probable hash type.
- `john --list-formats` shows the formats supported by the installed John version.
- The `raw-` prefix is required for some standard hash types.
- Misspecifying the format can prevent cracking or cause John to interpret the hash incorrectly.

## Linux Shadow Hashes

Linux password hashes are commonly stored in `/etc/shadow`, while usernames and account metadata are stored in `/etc/passwd`.

To prepare Linux password hashes for John, combine the passwd and shadow files with `unshadow`:

```bash
unshadow <path-to-passwd> <path-to-shadow> > unshadowed.txt
```

Then crack the resulting file:

```bash
john --wordlist=<path-to-wordlist> --format=sha512crypt unshadowed.txt
```

Operational notes:

- `/etc/shadow` is normally readable only by privileged users.
- `unshadow` combines account information with password hashes so John can associate hashes with usernames.
- `sha512crypt` is common on modern Linux systems, but the exact format should still be verified.

## Single Crack Mode

Single crack mode uses information already present in the target file, especially usernames and related account fields, to generate password guesses.

```bash
john --single --format=<format> <path-to-file>
```

Key concepts:

- Single crack mode focuses on user-specific password guesses.
- John can mangle words by changing letters, numbers, capitalization, and other patterns.
- GECOS fields can provide additional account-related words for password guessing.
- The target file should still use the structure:

```text
<username>:<hash>
```

Operational value:

- This mode is useful when users may base passwords on their names, usernames, or account metadata.
- It is often a good early step before using large generic wordlists.

## Custom Rules

Custom rules define word-mangling patterns that transform candidate passwords into more targeted guesses.

Rule configuration location:

```text
/etc/john/john.conf
```

Rule documentation:

```text
https://www.openwall.com/john/doc/RULES.shtml
```

Command pattern:

```bash
john --wordlist=<path-to-wordlist> --rule=<rule-name> <path-to-file>
```

Study notes:

- Custom rules are useful when you know or suspect a target password pattern.
- Rules can append numbers, alter capitalization, substitute characters, or otherwise transform wordlist entries.
- A well-targeted rule can be more efficient than blindly using a very large wordlist.

## ZIP Cracking

John cannot crack ZIP archives directly. First, convert the ZIP into a John-readable hash format using `zip2john`.

```bash
zip2john <path-to-zip-file> > outputfile
john --wordlist=<path-to-wordlist> outputfile
```

Operational notes:

- `zip2john` extracts the password hash material from the archive.
- John then cracks the generated output file, not the ZIP file directly.

## RAR Cracking

RAR archives follow the same workflow as ZIP archives: convert first, then crack.

```bash
rar2john <path-to-rar-file> > outputfile
john --wordlist=<path-to-wordlist> outputfile
```

Operational notes:

- `rar2john` prepares the RAR archive hash for John.
- The resulting output file is the file supplied to John.

## SSH Key Cracking

Encrypted SSH private keys, such as `id_rsa`, may require a passphrase. John can attempt to crack that passphrase after the key is converted into a supported hash format.

Primary command pattern:

```bash
ssh2john <path-to-id_rsa-private-key> > outputfile
john --wordlist=<path-to-wordlist> outputfile
```

Alternative when `ssh2john` is not installed as a direct command:

```bash
python3 /opt/john/ssh2john.py <path-to-id_rsa-private-key> > outputfile
john --wordlist=<path-to-wordlist> outputfile
```

Example:

```bash
john --wordlist=/usr/share/wordlists/rockyou.txt james.txt
```

Example result:

```text
james13
```

Operational notes:

- `ssh2john` converts an encrypted SSH private key into a John-readable hash.
- The recovered value is the SSH key passphrase, not necessarily the user account password.
- After recovering the passphrase, use it when authenticating with the private key.

## Quick Command Reference

| Task | Command Pattern |
|---|---|
| Crack with wordlist | `john --wordlist=<wordlist> <hash-file>` |
| Specify format | `john --format=<format> --wordlist=<wordlist> <hash-file>` |
| List supported formats | `john --list-formats` |
| Prepare Linux hashes | `unshadow <passwd> <shadow> > unshadowed.txt` |
| Single crack mode | `john --single --format=<format> <hash-file>` |
| Use custom rules | `john --wordlist=<wordlist> --rule=<rule-name> <hash-file>` |
| Prepare ZIP archive | `zip2john <zip-file> > outputfile` |
| Prepare RAR archive | `rar2john <rar-file> > outputfile` |
| Prepare SSH private key | `ssh2john <id_rsa> > outputfile` |

## Study Takeaways

- John needs hash material in a format it understands.
- Many file types must be converted first using helper tools such as `zip2john`, `rar2john`, or `ssh2john`.
- Correct hash format selection matters.
- Single crack mode and custom rules are useful for targeted cracking.
- Wordlist quality and target-specific rules often matter more than wordlist size.
